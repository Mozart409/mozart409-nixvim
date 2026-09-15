# AGENTS.md — mozart409-nixvim

Personal Neovim configuration built with [nixvim](https://github.com/nix-community/nixvim), distributed as a self-contained Home Manager module.

## Commands

| Command | What it does |
|---|---|
| `just run` | Launch nvim with this repo's config (isolated from `~/.config/nvim`) |
| `just build` | Compile-check the config (`nix build --no-link .#nvim`) |
| `just test` | Build + validate keymaps in headless nvim |
| `nix flake check` | Same as build, wired as a flake check |

The `.#nvim` package builds a self-contained binary that loads config via `-u <initFile>` — it does NOT depend on `~/.config/nvim`. This is the authoritative validation that the Nix config assembles and keymaps resolve.

## Architecture

```
flake.nix          — flake outputs: packages.nvim, checks.nvim, devShells, homeModules
nixvim.nix         — top-level nixvim config: keymaps, autocommands, global options, plugin imports
plugins/
  kickstart/plugins/  — upstream kickstart.nixvim plugin ports
  custom/plugins/     — personal plugin configs (add new plugins here, import in nixvim.nix)
  gitsigns.nix        — root-level custom plugin
  lsp.nix, mini.nix, nvim-cmp.nix, telescope.nix, treesitter.nix, which-key.nix — core plugins
scripts/test-keymaps.sh — headless keymap validation (3 contracts)
```

## Plugin workflow

1. Create a `.nix` file in `plugins/custom/plugins/`
2. Import it in `nixvim.nix` under the `imports = [...]` list (keep-sorted blocks)
3. `just test` to verify keymaps resolve and no `<leader>` prefix collisions

## Test suite (`scripts/test-keymaps.sh`)

Runs in a temporary HOME, never touches real config. Three contracts:
1. Every `<leader>` map listed in the expected pickers table calls its declared `snacks.picker` source
2. Every expected keymap is actually mapped and has an action
3. No `<leader>` key is a prefix of another `<leader>` key (avoids `timeoutlen` stalls)

Allowed prefix collisions are listed in `allowed_prefix_collisions` inside the script.

**Important:** `nix build` only validates Nix-level options. Bad Lua inside `__raw` blocks or invalid picker names only surface at runtime — always `just test` after changing keymaps or picker config.

## Key quirks

- **`__raw` Lua**: nixvim can embed raw Lua via `.__raw`. Nix cannot validate this content; errors appear only at runtime.
- **Home Manager module is self-contained**: importing `homeModules.default` (or `homeModules.nixvim`) pulls in nixvim automatically. Consumers do NOT need to add `nixvim.homeModules.nixvim` separately.
- **`homeModules.default` must stay top-level** (outside `eachDefaultSystem`) — nesting broke it for external consumers.
- **State version**: `26.05` (nixos-unstable).
- **Dev shell tools**: `just`, `deadnix`, `keep-sorted`, `lefthook`, `opencode`, `claude-code`, `cocogitto`

## Sorting

Import lists and dev shell packages use `keep-sorted` marker comments. Run `keep-sorted` (in dev shell) to maintain order.

## Linting

`deadnix` (dev shell) — detect unused Nix bindings.
`lefthook` — auto-installed via `shellHook`; check `lefthook.yml` for pre-commit/pre-push hooks.
