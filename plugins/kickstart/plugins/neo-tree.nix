{
  programs.nixvim = {
    plugins.neo-tree = {
      enable = true;
      settings = {
        add_blank_line_at_top = true;
        auto_clean_after_session_restore = true;
        close_if_last_window = true;
        filesystem = {
          hijack_netrw_behavior = "open_default";
          use_libuv_file_watcher = true;
          window.mappings."\\" = "close_window";
        };
      };
    };
    extraConfigLuaPost = ''
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          if data.file ~= nil and data.file ~= "" and vim.fn.isdirectory(data.file) == 1 then
            if data.buf ~= nil and vim.api.nvim_buf_is_valid(data.buf) then
              vim.api.nvim_buf_delete(data.buf, { force = true })
            end
            vim.cmd.cd(data.file)
          end
        end,
        desc = "Use neo-tree on directory startup and remove initial dir buffer",
      })
    '';
    keymaps = [
      {
        mode = "n";
        key = "<leader>fe";
        action = "<cmd>Neotree reveal<cr>";
        options.desc = "[F]ile [E]xplorer reveal (NeoTree)";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree reveal<cr>";
        options.desc = "[E]xplorer reveal (NeoTree)";
      }
    ];
  };
}
