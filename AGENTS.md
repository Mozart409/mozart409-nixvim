# AGENTS.md — mozart409-nixvim

Personal Neovim configuration built with [nixvim](https://github.com/nix-community/nixvim), distributed as a self-contained Home Manager module.

## Commands

| Command | What it does |
|---|---|
| `just run` | Launch nvim with this repo's config (isolated from `~/.config/nvim`) |
| `just build` | Compile-check the config (`nix build --no-link .#nvim`) |
| `just test` | Build + run `scripts/check-keymaps.lua` in headless nvim |
| `just fmt` | Format Nix files with alejandra |
| `just lint` | deadnix, statix, alejandra --check, keep-sorted lint |
| `nix flake check` | `checks.nvim` (build) + `checks.keymaps` (same Lua contracts, sandboxed) |

The `.#nvim` package builds a self-contained binary that loads config via `-u <initFile>` — it does NOT depend on `~/.config/nvim`. This is the authoritative validation that the Nix config assembles and keymaps resolve.

## Architecture

```
flake.nix          — flake outputs: packages.nvim, checks.{nvim,keymaps}, devShells, homeModules
nixvim.nix         — top-level nixvim config: options, diagnostics, keymaps, autocommands, plugin imports
plugins/
  kickstart/plugins/  — upstream kickstart.nixvim plugin ports (autopairs, indent-blankline, lint, neo-tree)
  custom/plugins/     — personal plugin configs (add new plugins here, import in nixvim.nix)
  conform.nix, gitsigns.nix, lsp.nix, treesitter.nix, which-key.nix — core plugins
scripts/check-keymaps.lua — headless contract checks (run by `just test` and `nix flake check`)
scripts/test-keymaps.sh   — local wrapper: builds .#nvim, runs the Lua in a throwaway HOME
```

Key plugin choices: `lsp.servers` (native `vim.lsp.config`, nvim-lspconfig only supplies default configs), blink.cmp, snacks.nvim (picker, dashboard, input, lazygit, image), lz.n lazy loading (`plugins.<name>.lazyLoad.settings` per plugin; `lzn-auto-require` makes `require()` in keymaps load lazy plugins), heirline statusline via `extraPlugins` (no nixvim module exists), vague colorscheme, nvim-web-devicons.

Unimported files under `plugins/` are kept on purpose (previous experiments: telescope, fzf-lua, nvim-cmp, mini, dressing, carbonfox, cyberdream, zenburn, comment, lazygit, dashboard, noice, opencode, fff, nvim-lightbulb, zk). They are not part of the build.

## Plugin workflow

1. Create a `.nix` file in `plugins/custom/plugins/`
2. Import it in `nixvim.nix` under the `imports = [...]` list (keep-sorted blocks)
3. `just test` to verify keymaps resolve and no `<leader>` prefix collisions

## Test suite (`scripts/check-keymaps.lua`)

Runs after `VimEnter` in a temporary HOME, never touches real config. Contracts:
1. Every `<leader>` map listed in the expected pickers table calls its declared `snacks.picker` source
2. Every expected keymap is actually mapped and has an action (LSP maps are buffer-local on attach and are not listed)
2b. Maps the config deliberately deletes (d2-vim defaults) are absent
3. No `<leader>` key is a prefix of another `<leader>` key (avoids `timeoutlen` stalls)
4. `:messages` contains no errors or deprecation notices after startup

Allowed prefix collisions are listed in `allowed_prefix_collisions` inside the script.

**Important:** `nix build` only validates Nix-level options. Bad Lua inside `__raw` blocks or invalid picker names only surface at runtime — always `just test` after changing keymaps or picker config.

## Key quirks

- **`__raw` Lua**: nixvim can embed raw Lua via `.__raw`. Nix cannot validate this content; errors appear only at runtime.
- **Home Manager module is self-contained**: importing `homeModules.default` (or `homeModules.nixvim`) pulls in nixvim automatically. Consumers do NOT need to add `nixvim.homeModules.nixvim` separately.
- **`homeModules.default` must stay top-level** (outside `eachDefaultSystem`) — nesting broke it for external consumers.
- **State version**: `26.05` (nixos-unstable).
- **No unfree packages** in the nvim closure — `packages.nvim` is built from plain `legacyPackages` so the flake check proves it. Unfree dev tools (claude-code, opencode) live only in the devShell.
- **Dev shell tools**: `just`, `alejandra`, `statix`, `deadnix`, `keep-sorted`, `lefthook`, `opencode`, `claude-code`, `cocogitto`

## Sorting

Import lists and dev shell packages use `keep-sorted` marker comments. Run `keep-sorted` (in dev shell) to maintain order.

## Linting / formatting

`just lint` — `deadnix --fail`, `statix check`, `alejandra --check`, `keep-sorted --mode lint`.
`just fmt` — `alejandra` (accepts file arguments; lefthook passes staged files).
`lefthook` — auto-installed via `shellHook`: pre-commit runs keep-sorted, deadnix, `just fmt`, `just --fmt`; pre-push runs `just lint` and `just test`.
