_: {
  programs.nixvim = {
    plugins.lint = {
      enable = true;
      lintersByFt = {
        nix = ["nix"];
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
