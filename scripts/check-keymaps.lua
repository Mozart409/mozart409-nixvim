-- Headless contract checks for the nixvim config. Run by scripts/test-keymaps.sh
-- (locally) and by `nix flake check` (checks.keymaps) against the built .#nvim.
--
-- Contracts:
--   1. every <leader> search map calls the snacks.picker source it claims to
--   2. every listed map exists and has an action (nothing silently vanished)
--   2b. maps the config deliberately removes at VimEnter are really gone
--   3. no <leader> map is a strict prefix of another (timeoutlen stalls)
--   4. startup leaves no errors or deprecation notices in :messages
--   5. the statusline renders with a diagnostic of every severity present
--
-- Exits 0 on PASS, non-zero on any violation.

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
  ["<leader>m"]   = "conform format buffer",
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
  ["grn"]         = "inc-rename on the builtin rename key",
  ["-"]           = "oil parent directory",
  ["]t"]          = "next todo comment",
  ["[t"]          = "previous todo comment",
}

-- CONTRACT 2b: maps the config deliberately removes at VimEnter must be gone.
local expected_absent = {
  ["<leader>yd2"] = "d2-vim default map, deleted in d2.nix",
}

-- CONTRACT 3: no <leader> map may be a strict prefix of another <leader> map.
-- When it is, the shorter one stalls for `timeoutlen` on every press while nvim
-- waits to see if the longer one is coming (this is what <leader>f = format vs
-- <leader>fe = explorer did). Unlike contracts 1 and 2 this needs no allowlist
-- upkeep — it catches the whole class. Operator-pending maps outside <leader>
-- (comment.nvim's gc/gb) are excluded: the wait is inherent to operators.
-- Add a genuinely intentional pair here as "<leader>x -> <leader>xy".
local allowed_prefix_collisions = {}

local function run_checks()
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

-- Contract 2b -------------------------------------------------------------
for _, key in ipairs(sorted_keys(expected_absent)) do
  if existing[expand(key)] then
    fails[#fails + 1] = key .. "  : mapped, but should have been removed (" .. expected_absent[key] .. ")"
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

-- Contract 4 --------------------------------------------------------------
-- Startup must be clean: no Lua/Vim errors and no deprecation notices in
-- the message history. Catches broken `__raw` blocks and API removals that
-- `nix build` cannot see.
local messages = vim.api.nvim_exec2("messages", { output = true }).output
for line in (messages .. "\n"):gmatch("([^\n]*)\n") do
  if line:match("^E%d+:") or line:match("Error") or line:match("[Dd]eprecat") or line:match("stack traceback") then
    fails[#fails + 1] = "startup message  : " .. line
  end
end
if vim.v.errmsg ~= "" then
  fails[#fails + 1] = "v:errmsg  : " .. vim.v.errmsg
end

-- Contract 5 --------------------------------------------------------------
-- The heirline Diagnostics component is gated on `has_diagnostics`, so a bad
-- highlight in it (an hl group name where a color belongs, say) never fires at
-- startup and only surfaces once an LSP reports something. Set one diagnostic
-- of every severity and force a full statusline eval so each branch renders.
local sev = vim.diagnostic.severity
local diag_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(diag_buf, 0, -1, false, { "x" })
vim.api.nvim_set_current_buf(diag_buf)
local diag_ns = vim.api.nvim_create_namespace("check-keymaps")
local ok_diag, diag_err = pcall(function()
  vim.diagnostic.set(diag_ns, diag_buf, {
    { lnum = 0, col = 0, message = "e", severity = sev.ERROR },
    { lnum = 0, col = 0, message = "w", severity = sev.WARN },
    { lnum = 0, col = 0, message = "i", severity = sev.INFO },
    { lnum = 0, col = 0, message = "h", severity = sev.HINT },
  })
  local ok_heirline, heirline = pcall(require, "heirline")
  if not ok_heirline then error("require('heirline') failed") end
  local rendered = heirline.statusline:eval()
  if type(rendered) ~= "string" or rendered == "" then
    error("statusline evaluated to " .. vim.inspect(rendered))
  end
end)
if not ok_diag then
  fails[#fails + 1] = "statusline with diagnostics  : " .. tostring(diag_err)
end
vim.diagnostic.reset(diag_ns, diag_buf)

-- Report ------------------------------------------------------------------
if #fails > 0 then
  io.stderr:write("FAIL: " .. #fails .. " problem(s):\n")
  for _, f in ipairs(fails) do io.stderr:write("  - " .. f .. "\n") end
  vim.cmd("cquit 1")
else
  io.stdout:write(string.format(
    "PASS: %d picker keymaps resolve, %d keymaps present, %d <leader> maps free of prefix collisions, startup clean, statusline renders diagnostics\n",
    #picker_keys, #map_keys, #leader_lhs))
  vim.cmd("quitall")
end
end

-- `-c` commands run BEFORE VimEnter, so anything the config does at VimEnter
-- (d2.nix's deferred keymap deletion, for one) would be invisible here. Wait
-- for VimEnter, then let two rounds of vim.schedule() drain first.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      vim.schedule(function()
        local ok, err = pcall(run_checks)
        if not ok then
          io.stderr:write("FAIL: check script errored: " .. tostring(err) .. "\n")
          vim.cmd("cquit 1")
        end
      end)
    end)
  end,
})
