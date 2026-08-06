#!/usr/bin/env bash
#
# Assert that the neovim config built from THIS repo actually registers its
# keymaps, that each snacks.picker source they call resolves to a real
# function, and that no <leader> map shadows another as a prefix.
#
# Why this exists: a keymap can silently vanish if its plugin file isn't
# imported in nixvim.nix, and `nix run .#nvim` used to mask that by falling
# through to your installed ~/.config/nvim. This test builds the self-contained
# `.#nvim` target (which loads its config via `-u <initFile>`), so it checks
# the repo's config, not whatever happens to be installed.
#
# Usage:  ./scripts/test-keymaps.sh        (or: just test)
# Exits non-zero if any contract below is violated.

set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Building .#nvim ..."
nvim_bin="$(nix build --no-link --print-out-paths .#nvim)/bin/nvim"

# Isolated HOME so we never touch the real ~/.config/nvim. The .#nvim target
# loads its config via `-u <initFile>`, so it doesn't need ~/.config at all.
tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT
# Pre-create the XDG dirs plugins expect (e.g. neo-tree's log), so they don't
# print spurious warnings into the test output.
mkdir -p "$tmp_home/.local/share/nvim" "$tmp_home/.local/state/nvim" \
  "$tmp_home/.cache/nvim" "$tmp_home/.config"

check_lua="$tmp_home/check.lua"
cat >"$check_lua" <<'LUA'
-- CONTRACT 1: each <leader> map must exist AND call this snacks.picker source.
-- Edit this table when you add/rename a search mapping.
local expected_pickers = {
  ["<leader>sh"]       = "help",
  ["<leader>sk"]       = "keymaps",
  ["<leader>sf"]       = "files",
  ["<leader>ss"]       = "pickers",
  ["<leader>sw"]       = "grep_word",
  ["<leader>sg"]       = "grep",
  ["<leader>sd"]       = "diagnostics",
  ["<leader>sr"]       = "resume",
  ["<leader>s."]       = "recent",
  ["<leader><leader>"] = "buffers",
  ["<leader>/"]        = "lines",
  ["<leader>s/"]       = "grep_buffers",
  ["<leader>sn"]       = "files",
}

-- CONTRACT 2: these maps must exist and have an action. No picker involved —
-- this is the "did it silently disappear?" net for everything else. Covering
-- every non-picker <leader> map means a dropped or renamed plugin import fails
-- here instead of being noticed months later in daily use.
local expected_maps = {
  ["<leader>fe"]  = "file explorer reveal (neo-tree)",
  ["<leader>e"]   = "file explorer reveal, short alias",
  ["<leader>cf"]  = "conform format buffer",
  ["<leader>cs"]  = "trouble symbols",
  ["<leader>a"]   = "aerial symbols toggle",
  ["<leader>S"]   = "spectre",
  ["<leader>lg"]  = "lazygit",
  ["<leader>rn"]  = "lsp rename",
  ["<leader>nc"]  = "neogen class doc",
  ["<leader>nf"]  = "neogen function doc",
  ["<leader>ng"]  = "neogen doc (auto-detect)",
  ["<leader>nt"]  = "neogen type doc",
  ["<leader>tp"]  = "toggle precognition",
  ["<leader>up"]  = "precognition peek",
  ["<leader>xx"]  = "trouble diagnostics",
  ["<leader>xX"]  = "trouble buffer diagnostics",
  ["<leader>xL"]  = "trouble location list",
  ["<leader>xQ"]  = "trouble quickfix list",
  ["<leader>yd2"] = "d2 preview copy",
}

-- CONTRACT 3: no <leader> map may be a strict prefix of another <leader> map.
-- When it is, the shorter one stalls for `timeoutlen` on every press while nvim
-- waits to see if the longer one is coming (this is what <leader>f = format vs
-- <leader>fe = explorer did). Unlike contracts 1 and 2 this needs no allowlist
-- upkeep — it catches the whole class. Operator-pending maps outside <leader>
-- (comment.nvim's gc/gb) are excluded: the wait is inherent to operators.
-- Add a genuinely intentional pair here as "<leader>x -> <leader>xy".
local allowed_prefix_collisions = {}

local leader = vim.g.mapleader or "\\"
local function expand(key) return (key:gsub("<leader>", leader)) end
local function pretty(lhs) return "<leader>" .. lhs:sub(#leader + 1) end

local ok_snacks, snacks = pcall(require, "snacks")
if not ok_snacks then
  io.stderr:write("FAIL: require('snacks') failed - snacks not enabled/imported\n")
  vim.cmd("cquit 1")
  return
end
local picker = snacks.picker

-- Index existing normal-mode maps by their (leader-expanded) lhs.
local existing = {}
local leader_lhs = {}
for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
  existing[m.lhs] = m
  if m.lhs:sub(1, #leader) == leader then leader_lhs[#leader_lhs + 1] = m.lhs end
end

local fails = {}
local function has_action(m)
  return m.callback ~= nil or (m.rhs ~= nil and m.rhs ~= "")
end
local function sorted_keys(t)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys)
  return keys
end

-- Contract 1 --------------------------------------------------------------
local picker_keys = sorted_keys(expected_pickers)
for _, key in ipairs(picker_keys) do
  local src = expected_pickers[key]
  local m = existing[expand(key)]
  if not m then
    fails[#fails + 1] = key .. "  : not mapped"
  elseif not has_action(m) then
    fails[#fails + 1] = key .. "  : mapped but has no action"
  end
  if type(picker[src]) ~= "function" then
    fails[#fails + 1] = key .. "  : snacks.picker." .. src .. " is not a function"
  end
end

-- Contract 2 --------------------------------------------------------------
local map_keys = sorted_keys(expected_maps)
for _, key in ipairs(map_keys) do
  local m = existing[expand(key)]
  if not m then
    fails[#fails + 1] = key .. "  : not mapped (" .. expected_maps[key] .. ")"
  elseif not has_action(m) then
    fails[#fails + 1] = key .. "  : mapped but has no action"
  end
end

-- Contract 3 --------------------------------------------------------------
table.sort(leader_lhs)
local collisions = 0
for _, short in ipairs(leader_lhs) do
  for _, long in ipairs(leader_lhs) do
    if #short < #long and long:sub(1, #short) == short then
      local pair = pretty(short) .. " -> " .. pretty(long)
      if not allowed_prefix_collisions[pair] then
        collisions = collisions + 1
        fails[#fails + 1] = pair
          .. "  : prefix collision, " .. pretty(short) .. " stalls for timeoutlen"
      end
    end
  end
end

-- Report ------------------------------------------------------------------
if #fails > 0 then
  io.stderr:write("FAIL: " .. #fails .. " problem(s):\n")
  for _, f in ipairs(fails) do io.stderr:write("  - " .. f .. "\n") end
  vim.cmd("cquit 1")
else
  io.stdout:write(string.format(
    "PASS: %d picker keymaps resolve, %d keymaps present, %d <leader> maps free of prefix collisions\n",
    #picker_keys, #map_keys, #leader_lhs))
  vim.cmd("quitall")
end
LUA

echo "==> Checking keymaps in a headless nvim ..."
HOME="$tmp_home" timeout 120 "$nvim_bin" --headless -c "luafile $check_lua"
