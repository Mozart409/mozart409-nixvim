{pkgs, ...}: {
  programs.nixvim = {
    # shellcheck is picked up by bashls, so it needs no nvim-lint entry.
    extraPackages = with pkgs; [
      # keep-sorted start
      deadnix
      shellcheck
      statix
      # keep-sorted end
    ];
    plugins.lint = {
      enable = true;
      lintersByFt = {
        nix = ["nix" "statix" "deadnix"];
      };
      autoCmd = {
        callback.__raw = ''
          function()
            require('lint').try_lint()
          end
        '';
        group = "lint";
        event = [
          "BufReadPost"
          "BufWritePost"
          "InsertLeave"
        ];
      };
    };
    autoGroups.lint.clear = true;
  };
}
