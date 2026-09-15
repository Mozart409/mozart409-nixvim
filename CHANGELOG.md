# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## 0.1.0 - 2026-09-15
#### Features
- (**cog**) add cog config - (2033201) - Amadeus Mader
- (**diagnostics**) add diagnostic signs and virtual lines - (77e5222) - Amadeus Mader
- (**flake**) add homemanager for local eval - (81b1edc) - Amadeus Mader
- (**flake**) add devshell - (8b5a91a) - Amadeus Mader
- (**oil**) add keymap - (33d263f) - Amadeus Mader
- (**oil**) configure oil - (a1d346a) - Amadeus Mader
- (**picker**) use snacks.picker for search mappings instead of Telescope - (9744076) - Amadeus Mader
- (**project**) :tada: init - (df661ae) - Amadeus Mader
- (**snacks**) show lua startup time not full c runtime process spwan etc - (34e7561) - Amadeus Mader
- (**snacks**) added dashboard and added more tools - (216a6ab) - Amadeus Mader
- (**test**) add test script - (b0e9ffc) - Amadeus Mader
- (**tools**) add justfile - (2a65e80) - Amadeus Mader
- (**tools**) add deadnix - (8512d7e) - Amadeus Mader
- (**treesitter**) add all Gramas and tree-sitter cli - (d717413) - Amadeus Mader
- add blink-cmp and lz-n plugins - (df156cd) - Amadeus Mader
#### Bug Fixes
- (**cog**) use cog config - (c6bc3b9) - Amadeus Mader
- (**config**) remove comments are they are redundent - (f12ec40) - Amadeus Mader
- (**d2**) remove default leader mappings, keep syntax only - (03a1e64) - Amadeus Mader
- (**flake**) kept top level module - (499cdee) - Amadeus Mader
- (**flake**) make nvim test target load config standalone - (cff5b68) - Amadeus Mader
- (**keymaps**) restore <leader>fe explorer and move format to <leader>cf - (26cd0d8) - Amadeus Mader
- (**keymaps**) bind trouble and format maps to normal mode only - (f9da9f3) - Amadeus Mader
- (**keymaps**) drop neogit maps and move explorer off the <leader>f prefix - (6a8e682) - Amadeus Mader
- (**lsp**) migrate pickers to snacks and stop shadowing the gr prefix - (9403f11) - Amadeus Mader
- (**nixvim**) enable snacks - (d7f153b) - Amadeus Mader
- (**oil**) disable oild file picker - (f566479) - Amadeus Mader
- (**snacks**) use full imagemagick, light build lacks image delegates - (5b70cbf) - Amadeus Mader
- (**snacks**) rebind picker tab to navigation, ctrl+space to select - (ce1dff3) - Amadeus Mader
- (**test**) silence warning for neo-tree - (09c0ebc) - Amadeus Mader
- (**tools**) remove all files - (b894bd9) - Amadeus Mader
- (**treesitter**) use native nixvim options and drop ensureInstalled - (94112a3) - Amadeus Mader
- typo - (cf61e58) - Amadeus Mader
- remove comments - (dbec523) - Amadeus Mader
#### Documentation
- (**agents**) add Agents - (5454356) - Amadeus Mader
- (**readme**) :memo: Update readme - (868530a) - Amadeus Mader
#### Tests
- (**keymaps**) extract contracts to dedicated Lua file - (6eda340) - Amadeus Mader
- (**keymaps**) add absent keymap contract and VimEnter timing - (d9d819b) - Amadeus Mader
- (**keymaps**) assert non-picker maps exist and no leader prefix collides - (c477f0f) - Amadeus Mader
#### Refactoring
- (**gitsigns**) add on_attach keymaps - (047a4a7) - Amadeus Mader
- (**lsp**) simplify config and streamline keymaps - (5cfad00) - Amadeus Mader
- (**plugins**) simplify core and custom plugin configs - (4041ebc) - Amadeus Mader
- (**precognition**) migrate to native nixvim options - (1ed4ac4) - Amadeus Mader
- (**snacks**) migrate to native options and add lazygit - (0df8c1c) - Amadeus Mader
- (**which-key**) expand key groups - (cd4c51c) - Amadeus Mader
- change format keymap from <leader>cf to <leader>m - (0a00160) - Amadeus Mader
#### Miscellaneous Chores
- (**cleanup**) drop unimported alpha.nix and empty git hunk group - (d2181fc) - Amadeus Mader
- (**deps**) upgrade flake - (23955c2) - Amadeus Mader
- (**deps**) upgrade flake - (81fddf4) - Amadeus Mader
- (**deps**) upgrade flake - (738d58e) - Amadeus Mader
- (**deps**) upgrade deps - (433f14a) - Amadeus Mader
- (**deps**) upgrade flake - (75f463c) - Amadeus Mader
- (**deps**) upgrade flake.lock - (79ffb31) - Amadeus Mader
- (**keep-sorted**) add more keep-sorted markers - (35ce62e) - Amadeus Mader
- (**theme**) switch to carbonfox - (86b1bf4) - Amadeus Mader
- (**tooling**) add fmt/lint recipes and simplify lefthook - (99eac9b) - Amadeus Mader
- (**tools**) run deadnix on all files - (4303c18) - Amadeus Mader
- (**tools**) add deadnix --fail to allfiles - (f62ebe5) - Amadeus Mader
- (**tools**) update lefthook - (98f86f8) - Amadeus Mader
- (**treesitter**) remove dead textobjects config - (e99297f) - Amadeus Mader
- remove flake-utils and add multi-system support - (7430914) - Amadeus Mader
- remove mini.nix and enable web-devicons - (ba55be0) - Amadeus Mader
- simplify nixvim.nix - (aa88298) - Amadeus Mader
- simplify core plugins - (76087a1) - Amadeus Mader
- simplify kickstart plugins - (73fedf5) - Amadeus Mader
- simplify custom plugins and add lazy loading - (a8d283f) - Amadeus Mader
- add sync-remote command to justfile - (626a1c1) - Amadeus Mader

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).