{
  programs.nixvim = {
    plugins.inc-rename = {
      enable = true;
      settings = {
        cmd_name = "IncRename";
        hl_group = "Substitute";
        preview_empty_name = false;
        show_message = true;
        input_buffer_type = "snacks";
      };
      lazyLoad.settings = {
        event = ["LspAttach"];
        cmd = ["IncRename"];
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>rn";
        action.__raw = ''
          function()
            return ":IncRename " .. vim.fn.expand("<cword>")
          end
        '';
        options = {
          expr = true;
          desc = "LSP: [R]e[n]ame with preview";
        };
      }
      {
        mode = "n";
        key = "grn";
        action.__raw = ''
          function()
            return ":IncRename " .. vim.fn.expand("<cword>")
          end
        '';
        options = {
          expr = true;
          desc = "LSP: [R]e[n]ame with preview";
        };
      }
    ];
  };
}
