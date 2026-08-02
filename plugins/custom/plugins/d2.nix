{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      d2-vim
    ];

    # Lazy-load on d2 filetype
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

      # d2-vim's plugin/d2.vim unconditionally claims <Leader>d2, <Leader>rd2
      # and <Leader>yd2 globally (no opt-out global to set). We only want the
      # syntax support, and those maps squat inside the which-key [D]ocument
      # and [R]ename groups with no description. Drop them once the plugin's
      # own plugin/ scripts have been sourced -- the commands (:D2Preview*,
      # :D2ReplaceSelection) stay available.
      {
        event = ["VimEnter"];
        desc = "Remove d2-vim's default <Leader> mappings";
        callback.__raw = ''
          function()
            -- Deferred to the end of startup so it lands after plugin/d2.vim
            -- has been sourced, whatever the load order works out to be.
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
