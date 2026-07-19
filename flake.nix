{
  description = "Mozart409's Neovim configuration, built with nixvim and exposed as a Home Manager module";

  inputs = {
    # keep-sorted start block=yes
    flake-utils.url = "github:numtide/flake-utils";
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
    flake-utils,
    home-manager,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      # Fully-configured neovim, built by evaluating the Home Manager module
      # in a throwaway HM config. This is the real test that the config is
      # valid at the Nix level (all nixvim option names/types check out and
      # init.lua assembles):
      #
      #   nix build .#nvim        # compile-check the config
      #   nix run   .#nvim        # launch it isolated to eyeball runtime/Lua
      #   nix flake check         # same build, wired as a flake check
      #
      # Note: Nix can't validate the Lua inside `__raw`/plugin config — a bad
      # picker name only surfaces at runtime, so still smoke-test with `nix run`.
      #
      # In Home Manager mode `build.package` is NOT self-contained: it relies on
      # the generated init.lua being written to ~/.config/nvim by HM. So we wrap
      # the package's nvim with `-u <build.initFile>` to get a genuinely
      # standalone, config-loaded editor that runs correctly under any HOME.
      packages.nvim = let
        nixvimCfg =
          (home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              # Same content as homeModules.default, inlined to avoid a
              # self-reference (flake-utils nests homeModules under <system>).
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

      checks.nvim = self.packages.${system}.nvim;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # keep-sorted start
          claude-code
          cocogitto
          deadnix
          just
          keep-sorted
          lefthook
          opencode
          # keep-sorted end
        ];
        shellHook = ''
          lefthook install
        '';
      };

      # Home Manager module.
      #
      # Import it in your home.nix:
      #   imports = [ inputs.mozart409-nixvim.homeModules.default ];
      #
      # It is self-contained: it pulls in nixvim's own Home Manager module,
      # so you do NOT need to add `nixvim.homeModules.nixvim` separately. This
      # is what lets the config run at work with only Nix + Home Manager and no
      # NixOS.
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
    });
}
