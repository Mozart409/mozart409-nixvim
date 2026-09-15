{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      d2-vim
    ];
    autoCmd = [
      {
        event = ["FileType"];
        pattern = ["d2"];
        callback.__raw = ''
          function()
            vim.bo.commentstring = "# %s"
          end
        '';
      }
      {
        event = ["VimEnter"];
        desc = "Remove d2-vim's default <Leader> mappings";
        callback.__raw = ''
          function()
            vim.schedule(function()
              pcall(vim.keymap.del, "v", "<Leader>d2")
              pcall(vim.keymap.del, "v", "<Leader>rd2")
              pcall(vim.keymap.del, "n", "<Leader>yd2")
            end)
          end
        '';
      }
    ];
  };
}
