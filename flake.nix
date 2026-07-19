{
  description = "Mozart409's Neovim configuration, built with nixvim and exposed as a Home Manager module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    nixvim,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # keep-sorted start
          lefthook
          opencode
          cocogitto
          claude-code
          keep-sorted
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
          nixvim.homeModules.nixvim
          ./nixvim.nix
        ];

        # Pin nixvim's nixpkgs to the consuming system's pkgs — silences the
        # warning about `inputs.nixvim.inputs.nixpkgs.follows` skewing the default.
        programs.nixvim.nixpkgs.source = pkgs.path;
      };

      # Alias so `homeModules.nixvim` also works.
      homeModules.nixvim = self.homeModules.default;
    });
}
