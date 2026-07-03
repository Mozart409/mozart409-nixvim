# mozart409-nixvim

My personal Neovim configuration, built with [nixvim](https://github.com/nix-community/nixvim), distributed as a self-contained Home Manager module.

## Features

- Modular plugin configuration — each plugin lives in its own `.nix` file under `plugins/`
- LSP, completion (nvim-cmp), Tree-sitter, Telescope/FZF-Lua, linting, formatting
- Git integration (Neogit, Gitsigns), Oil file explorer, Trouble diagnostics, and more
- Nerd Font support with web-devicons
- Wayland and X11 clipboard support

## Requirements

- **Nix** with flakes enabled
- [Home Manager](https://github.com/nix-community/home-manager) (standalone or as a NixOS module)
- A [Nerd Font](https://www.nerdfonts.com/) (optional, for icons)

### External Tools (for full plugin functionality)

- `git`, `gcc`
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- Clipboard tool (`wl-clipboard` on Wayland, `xclip`/`xsel` on X11)
- Language toolchains as needed (e.g. `go`, `nodejs`, `rustc`)

## Installation

### Method 1: Flake + Home Manager (recommended)

Add this repo as an input in your system/home flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mozart409-nixvim.url = "github:mozart409/mozart409-nixvim";
    # Override nixpkgs so nixvim uses the same revision as the rest of your system
    mozart409-nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, mozart409-nixvim, ... }: {
    # ... your home-manager configuration ...
    homeConfigurations."your-user" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        mozart409-nixvim.homeModules.default
        # ... other modules ...
      ];
    };
  };
}
```

The module is self-contained: it imports nixvim's Home Manager module internally, so you do **not** need to add `nixvim.homeModules.nixvim` separately.

You can also import it in a standalone `home.nix`:

```nix
{ inputs, ... }: {
  imports = [ inputs.mozart409-nixvim.homeModules.default ];
}
```

Once added, rebuild your Home Manager generation:

```sh
home-manager switch --flake .
```

### Method 2: NixOS Module (without flakes)

Clone the repo and import `nixvim.nix` directly into your `configuration.nix`:

```sh
git clone https://github.com/mozart409/mozart409-nixvim.git /etc/nixos/mozart409-nixvim
```

Then add the nixvim Home Manager module to your `configuration.nix`:

```nix
{ config, pkgs, ... }:
let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
  });
in {
  imports = [
    nixvim.homeManagerModules.nixvim
    ./mozart409-nixvim/nixvim.nix
  ];
}
```

Rebuild with:

```sh
nixos-rebuild switch
```

### Method 3: Standalone Home Manager (without flakes)

Clone the repo and import directly in your `home.nix`:

```sh
git clone https://github.com/mozart409/mozart409-nixvim.git ~/.config/home-manager/mozart409-nixvim
```

```nix
{ config, pkgs, ... }:
let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
  });
in {
  imports = [
    nixvim.homeManagerModules.nixvim
    ./mozart409-nixvim/nixvim.nix
  ];
}
```

Rebuild with:

```sh
home-manager switch
```

## Customization

Fork this repo and edit the config to your liking:

- **`nixvim.nix`** — top-level options, keymaps, auto commands, and plugin imports
- **`plugins/`** — individual plugin configurations; add new plugins here and import them in `nixvim.nix`

Change the `flake.nix` input URL to point to your fork, or reference it locally:

```nix
mozart409-nixvim.url = "path:/home/your-user/path/to/mozart409-nixvim";
```

## Uninstalling

1. Remove the import from your Home Manager / NixOS configuration
2. Delete `~/.local/share/nvim/`
3. Rebuild your configuration

## Adapted From

This configuration is adapted from the following projects:

- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) — a launch point for your personal Neovim configuration
- [kickstart.nixvim](https://github.com/JMartJonesy/kickstart.nixvim) — a Nix port of kickstart.nvim built with nixvim

This repo started as a fork of kickstart.nixvim and has been heavily customized into my personal setup.
