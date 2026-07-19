#!/usr/bin/env bash
#
# Assert that the neovim config built from THIS repo actually registers the
# search keymaps and that each snacks.picker source they call resolves to a
# real function.
#
# Why this exists: a keymap can silently vanish if its plugin file isn't
# imported in nixvim.nix, and `nix run .#nvim` used to mask that by falling
# through to your installed ~/.config/nvim. This test builds the self-contained
# `.#nvim` target (which loads its config via `-u <initFile>`), so it checks
# the repo's config, not whatever happens to be installed.
#
# Usage:  ./scripts/test-keymaps.sh        (or: just test-keymaps)
# Exits non-zero on the first missing keymap / unresolved picker source.

set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Building .#nvim ..."
nvim_bin="$(nix build --no-link --print-out-paths .#nvim)/bin/nvim"

# Isolated HOME so we never touch the real ~/.config/nvim. The .#nvim target
# loads its config via `-u <initFile>`, so it doesn't need ~/.config at all.
tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT

check_lua="$tmp_home/check.lua"
cat >"$check_lua" <<'LUA'
-- Contract: each <leader> map must exist AND call this snacks.picker source.
-- Edit this table when you add/rename a search mapping.
local expected = {
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

local leader = vim.g.mapleader or "\\"

local ok_snacks, snacks = pcall(require, "snacks")
if not ok_snacks then
  io.stderr:write("FAIL: require('snacks') failed — snacks not enabled/imported\n")
  vim.cmd("cquit 1")
  return
end
local picker = snacks.picker

-- Index existing normal-mode maps by their (leader-expanded) lhs.
local existing = {}
for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
  existing[m.lhs] = m
end

local fails = {}
-- Sort keys for stable output.
local keys = {}
for k in pairs(expected) do keys[#keys + 1] = k end
table.sort(keys)

for _, key in ipairs(keys) do
  local src = expected[key]
  local lhs = (key:gsub("<leader>", leader)) -- "<leader>sg" -> " sg"
  local m = existing[lhs]
  if not m then
    fails[#fails + 1] = key .. "  : not mapped"
  elseif not (m.callback or (m.rhs and m.rhs ~= "")) then
    fails[#fails + 1] = key .. "  : mapped but has no action"
  end
  if type(picker[src]) ~= "function" then
    fails[#fails + 1] = key .. "  : snacks.picker." .. src .. " is not a function"
  end
end

if #fails > 0 then
  io.stderr:write("FAIL: " .. #fails .. " problem(s):\n")
  for _, f in ipairs(fails) do io.stderr:write("  - " .. f .. "\n") end
  vim.cmd("cquit 1")
else
  io.stdout:write("PASS: " .. #keys .. " search keymaps present and snacks.picker sources resolve\n")
  vim.cmd("quitall")
end
LUA

echo "==> Checking keymaps in a headless nvim ..."
HOME="$tmp_home" timeout 120 "$nvim_bin" --headless -c "luafile $check_lua"
