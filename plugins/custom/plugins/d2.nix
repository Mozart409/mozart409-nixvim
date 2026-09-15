{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.d2-vim;
        optional = true;
      }
    ];
    filetype.extension.d2 = "d2";
    plugins.lz-n.plugins = [
      {
        __unkeyed-1 = "d2-vim";
        ft = ["d2"];
        after.__raw = ''
          function()
            pcall(vim.keymap.del, "v", "<Leader>d2")
            pcall(vim.keymap.del, "v", "<Leader>rd2")
            pcall(vim.keymap.del, "n", "<Leader>yd2")
          end
        '';
      }
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
    ];
  };
}
