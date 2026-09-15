{
  description = "Mozart409's Neovim configuration, built with nixvim and exposed as a Home Manager module";

  inputs = {
    # keep-sorted start block=yes
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs = {
    self,
    nixpkgs,
    nixvim,
    home-manager,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
  in {
    # Fully-configured neovim, built by evaluating the Home Manager module
    # in a throwaway HM config. This is the real test that the config is
    # valid at the Nix level (all nixvim option names/types check out and
    # init.lua assembles):
    #
    #   nix build .#nvim        # compile-check the config
    #   nix run   .#nvim        # launch it isolated to eyeball runtime/Lua
    #   nix flake check         # build + run scripts/check-keymaps.lua
    #
    # Built from plain `legacyPackages` (no allowUnfree) on purpose: if this
    # evaluates, consumers of the Home Manager module don't need unfree either.
    #
    # In Home Manager mode `build.package` is NOT self-contained: it relies on
    # the generated init.lua being written to ~/.config/nvim by HM. So we wrap
    # the package's nvim with `-u <build.initFile>` to get a genuinely
    # standalone, config-loaded editor that runs correctly under any HOME.
    packages = forAllSystems (pkgs: {
      nvim = let
        nixvimCfg =
          (home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              # Same content as homeModules.default, inlined to keep this
              # per-system build free of a self-reference.
              ./nixvim.nix
              nixvim.homeModules.nixvim
              {
                programs.nixvim.nixpkgs.source = pkgs.path;
                home = {
                  username = "nixvim-test";
                  homeDirectory = "/tmp/nixvim-test";
                  stateVersion = "26.05";
                };
              }
            ];
          })
          .config
          .programs
          .nixvim;
      in
        pkgs.writeShellScriptBin "nvim" ''
          exec ${nixvimCfg.build.package}/bin/nvim -u ${nixvimCfg.build.initFile} "$@"
        '';
    });

    checks = forAllSystems (pkgs: let
      nvim = self.packages.${pkgs.stdenv.hostPlatform.system}.nvim;
    in {
      inherit nvim;

      # Runtime contracts (keymaps resolve, no prefix collisions, clean
      # startup) — the same Lua that `just test` runs, in the sandbox.
      keymaps =
        pkgs.runCommand "nixvim-check-keymaps" {
          nativeBuildInputs = [nvim];
        } ''
          export HOME=$TMPDIR/home
          mkdir -p $HOME/.local/share/nvim $HOME/.local/state/nvim $HOME/.cache/nvim $HOME/.config
          cd ${self}
          nvim --headless -c "luafile scripts/check-keymaps.lua"
          touch $out
        '';
    });

    devShells = forAllSystems (pkgs: let
      # claude-code and opencode are unfree; keep that confined to the dev shell.
      unfree = import pkgs.path {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # keep-sorted start
          alejandra
          cocogitto
          deadnix
          just
          keep-sorted
          lefthook
          statix
          unfree.claude-code
          unfree.opencode
          # keep-sorted end
        ];
        shellHook = ''
          lefthook install
        '';
      };
    });

    # Home Manager module.
    #
    # Import it in your home.nix:
    #   imports = [ inputs.mozart409-nixvim.homeModules.default ];
    #
    # It is self-contained: it pulls in nixvim's own Home Manager module,
    # so you do NOT need to add `nixvim.homeModules.nixvim` separately. This
    # is what lets the config run at work with only Nix + Home Manager and no
    # NixOS.
    #
    # Kept system-agnostic (not nested under <system>) because Home Manager
    # modules are — nesting them under <system> is what broke
    # `homeModules.default` for consumers.
    homeModules.default = {pkgs, ...}: {
      imports = [
        # keep-sorted start
        ./nixvim.nix
        nixvim.homeModules.nixvim
        # keep-sorted end
      ];

      # Pin nixvim's nixpkgs to the consuming system's pkgs — silences the
      # warning about `inputs.nixvim.inputs.nixpkgs.follows` skewing the default.
      programs.nixvim.nixpkgs.source = pkgs.path;
    };

    # Alias so `homeModules.nixvim` also works.
    homeModules.nixvim = self.homeModules.default;
  };
}
