{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.nixvim = {
    extraPackages = with pkgs; [
      tree-sitter
    ];
    plugins.treesitter = {
      enable = true;
      highlight = {
        enable = true;
        enableVimSyntax = true;
      };
      indent = {
        enable = true;
        disable = ["ruby"];
      };
      grammarPackages =
        builtins.filter
        (g: !(lib.hasInfix "qmljs" g.name))
        config.programs.nixvim.plugins.treesitter.package.allGrammars;
    };
  };
}
