-- Headless contract checks for the nixvim config. Run by scripts/test-keymaps.sh
-- (locally) and by `nix flake check` (checks.keymaps) against the built .#nvim.
--
-- Contracts:
--   1. every <leader> search map calls the snacks.picker source it claims to
--   2. every listed map exists and has an action (nothing silently vanished)
--   2b. maps the config deliberately removes at VimEnter are really gone
--   2c. pressing the lazygit maps calls the Snacks.lazygit entry point they claim to
--   2d. pressing the file explorer maps really opens neo-tree
--   2e. neo-tree lists .env files even though they are dotfiles
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
  ["<leader>st"]       = "todo_comments",
}

-- Picker sources registered by a lazy-loaded plugin's setup. The keymap
-- require()s the plugin first; do the same before checking the source exists.
local picker_requires = {
  ["<leader>st"] = "todo-comments",
}

-- CONTRACT 2: these maps must exist and have an action. No picker involved —
-- this is the "did it silently disappear?" net for everything else. Covering
-- every non-picker <leader> map means a dropped or renamed plugin import fails
-- here instead of being noticed months later in daily use.
local expected_maps = {
  ["<leader>fe"]  = "file explorer reveal (neo-tree)",
  ["<leader>e"]   = "file explorer reveal, short alias",
  ["<leader>m"]   = "conform format buffer",
  ["<leader>a"]   = "aerial symbols toggle",
  ["<leader>S"]   = "grug-far search and replace",
  ["<leader>q"]   = "diagnostics to loclist (global, not LSP-only)",
  ["<leader>lg"]  = "lazygit",
  ["<leader>gl"]  = "lazygit log",
  ["<leader>gf"]  = "lazygit file history",
  ["<leader>gb"]  = "git browse",
  ["<leader>bd"]  = "buffer delete",
  ["<leader>bo"]  = "buffer delete others",
  ["<C-/>"]       = "toggle terminal",
  ["s"]           = "flash jump",
  ["S"]           = "flash treesitter",
  ["]f"]          = "next function (treesitter-textobjects)",
  ["[f"]          = "previous function (treesitter-textobjects)",
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
  ["]t"]          = "next todo comment",
  ["[t"]          = "previous todo comment",
}

-- CONTRACT 2b: maps the config deliberately removes at VimEnter must be gone.
local expected_absent = {
  ["<leader>yd2"] = "d2-vim default map, deleted in d2.nix",
}

-- CONTRACT 2c: pressing these keys must call the named Snacks.lazygit entry
-- point. Snacks.lazygit is stubbed for the press, so lazygit never launches
-- (the binary isn't in the check sandbox). "" means Snacks.lazygit() itself.
local expected_lazygit = {
  ["<leader>lg"] = "",
  ["<leader>gl"] = "log",
  ["<leader>gf"] = "log_file",
}

-- CONTRACT 2d: pressing these keys must open a window of this filetype. The
-- real plugin runs; the window is closed again afterwards.
local expected_windows = {
  ["<leader>fe"] = "neo-tree",
  ["<leader>e"]  = "neo-tree",
}

-- CONTRACT 2e: neo-tree must list these files in a fresh directory even
-- though they are dotfiles (filesystem.filtered_items.always_show_by_pattern).
local expected_neo_tree_files = { ".env", ".env.local" }

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
-- Captured before the key presses below reset it; contract 4 checks it.
local startup_errmsg = vim.v.errmsg

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
-- Type the keys as a user would (remappable, executed before returning), so the
-- real map dispatch runs rather than a direct call of its callback. Returns an
-- error string, or nil when the press left no error behind.
local function press(key)
  vim.v.errmsg = ""
  local keys = vim.api.nvim_replace_termcodes(expand(key), true, false, true)
  local ok, err = pcall(vim.api.nvim_feedkeys, keys, "mx", false)
  if not ok then return tostring(err) end
  if vim.v.errmsg ~= "" then return vim.v.errmsg end
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
  if picker_requires[key] then
    local ok_req, req_err = pcall(require, picker_requires[key])
    if not ok_req then
      fails[#fails + 1] = key .. "  : require('" .. picker_requires[key] .. "') failed: " .. tostring(req_err)
    end
  end
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

-- Contract 2c -------------------------------------------------------------
local lazygit_keys = sorted_keys(expected_lazygit)
local real_lazygit = snacks.lazygit
for _, key in ipairs(lazygit_keys) do
  local want = expected_lazygit[key]
  local called
  local function record(name) return function() called = name end end
  snacks.lazygit = setmetatable(
    { log = record("log"), log_file = record("log_file") },
    { __call = record("") })
  if not existing[expand(key)] then
    fails[#fails + 1] = key .. "  : not mapped (lazygit)"
  else
    local press_err = press(key)
    if press_err then
      fails[#fails + 1] = key .. "  : pressing it errored: " .. press_err
    elseif called ~= want then
      local function label(name) return "Snacks.lazygit" .. (name == "" and "()" or "." .. name .. "()") end
      fails[#fails + 1] = key .. "  : expected " .. label(want) .. ", got "
        .. (called and label(called) or "no lazygit call")
    end
  end
end
snacks.lazygit = real_lazygit

-- Contract 2d -------------------------------------------------------------
local window_keys = sorted_keys(expected_windows)
for _, key in ipairs(window_keys) do
  local ft = expected_windows[key]
  local function find_windows()
    local wins = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == ft then wins[#wins + 1] = win end
    end
    return wins
  end
  if not existing[expand(key)] then
    fails[#fails + 1] = key .. "  : not mapped (opens " .. ft .. ")"
  else
    local press_err = press(key)
    -- Plugins may render asynchronously; vim.wait keeps the event loop running.
    local opened = vim.wait(3000, function() return #find_windows() > 0 end, 20)
    if press_err then
      fails[#fails + 1] = key .. "  : pressing it errored: " .. press_err
    elseif not opened then
      fails[#fails + 1] = key .. "  : pressed, but no " .. ft .. " window opened"
    end
    for _, win in ipairs(find_windows()) do
      if #vim.api.nvim_list_wins() > 1 then pcall(vim.api.nvim_win_close, win, true) end
    end
  end
end

-- Contract 2e -------------------------------------------------------------
local env_dir = vim.fn.tempname()
vim.fn.mkdir(env_dir, "p")
for _, name in ipairs(expected_neo_tree_files) do
  vim.fn.writefile({ "X=1" }, env_dir .. "/" .. name)
end
local function neo_tree_lines()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    end
  end
end
local function lists_all(text)
  text = "\n" .. text .. "\n"
  for _, name in ipairs(expected_neo_tree_files) do
    -- Whitespace on both sides, so ".env" can't match inside ".env.local".
    if not text:find("%s" .. vim.pesc(name) .. "%s") then return false end
  end
  return true
end
local ok_tree, tree_err = pcall(vim.cmd, "Neotree dir=" .. vim.fn.fnameescape(env_dir))
local listed = ok_tree and vim.wait(3000, function()
  local text = neo_tree_lines()
  return text ~= nil and lists_all(text)
end, 20)
if not ok_tree then
  fails[#fails + 1] = "neo-tree .env files  : :Neotree errored: " .. tostring(tree_err)
elseif not listed then
  fails[#fails + 1] = "neo-tree .env files  : expected " .. table.concat(expected_neo_tree_files, ", ")
    .. " listed, tree showed: " .. vim.inspect(neo_tree_lines())
end
pcall(vim.cmd, "Neotree close")
vim.fn.delete(env_dir, "rf")

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
if startup_errmsg ~= "" then
  fails[#fails + 1] = "v:errmsg  : " .. startup_errmsg
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
    "PASS: %d picker keymaps resolve, %d keymaps present, %d lazygit maps wired, %d window maps open, neo-tree shows .env, %d <leader> maps free of prefix collisions, startup clean, statusline renders diagnostics\n",
    #picker_keys, #map_keys, #lazygit_keys, #window_keys, #leader_lhs))
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
