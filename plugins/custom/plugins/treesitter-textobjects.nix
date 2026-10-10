{
  programs.nixvim = let
    select = key: query: desc: {
      mode = ["x" "o"];
      inherit key;
      action.__raw = ''
        function()
          require('nvim-treesitter-textobjects.select').select_textobject('${query}', 'textobjects')
        end
      '';
      options.desc = desc;
    };
    move = key: fn: query: desc: {
      mode = ["n" "x" "o"];
      inherit key;
      action.__raw = ''
        function()
          require('nvim-treesitter-textobjects.move').${fn}('${query}', 'textobjects')
        end
      '';
      options.desc = desc;
    };
  in {
    plugins.treesitter-textobjects.enable = true;
    extraConfigLua = ''
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
    '';
    keymaps = [
      (select "af" "@function.outer" "around function")
      (select "if" "@function.inner" "inside function")
      (select "ac" "@class.outer" "around class")
      (select "ic" "@class.inner" "inside class")
      (select "aa" "@parameter.outer" "around argument")
      (select "ia" "@parameter.inner" "inside argument")
      (move "]f" "goto_next_start" "@function.outer" "Next function start")
      (move "[f" "goto_previous_start" "@function.outer" "Previous function start")
      (move "]F" "goto_next_end" "@function.outer" "Next function end")
      (move "[F" "goto_previous_end" "@function.outer" "Previous function end")
    ];
  };
}
