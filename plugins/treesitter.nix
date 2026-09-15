{pkgs, ...}: {
  programs.nixvim = {
    extraPackages = with pkgs; [
      tree-sitter
    ];
    plugins.treesitter = {
      enable = true;
      highlight = {
        enable = true;
        enableVimSyntax = ["ruby"];
      };
      indent = {
        enable = true;
        disable = ["ruby"];
      };
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        # keep-sorted start
        bash
        c
        cpp
        css
        csv
        cue
        diff
        dockerfile
        editorconfig
        git_config
        git_rebase
        gitattributes
        gitcommit
        gitignore
        go
        gomod
        gosum
        gowork
        hcl
        html
        http
        ini
        javascript
        jsdoc
        json
        json5
        just
        latex
        lua
        luadoc
        luap
        make
        markdown
        markdown_inline
        nix
        proto
        python
        query
        regex
        rust
        scss
        sql
        ssh_config
        templ
        terraform
        toml
        tsx
        typescript
        typst
        vim
        vimdoc
        xml
        yaml
        # keep-sorted end
      ];
    };
  };
}
