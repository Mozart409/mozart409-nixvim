{
  programs.nixvim = {
    plugins.nvim-bqf = {
      enable = true;
      lazyLoad.settings.ft = ["qf"];
      settings = {
        auto_enable = true;
        auto_resize_height = true;
        preview = {
          auto_preview = true;
          border = "rounded";
          show_title = true;
          show_scroll_bar = true;
          delay_syntax = 80;
          win_height = 12;
          win_vheight = 12;
          winblend = 12;
          wrap = false;
          buf_label = true;
        };
        func_map = {
          split = "<C-s>";
          vsplit = "<C-v>";
          ptogglemode = "z,";
          pscrollup = "<C-b>";
          pscrolldown = "<C-f>";
          pscrollorig = "zo";
          prevfile = "<C-p>";
          nextfile = "<C-n>";
          stoggleup = "<S-Tab>";
          stoggledown = "<Tab>";
          stogglevm = "<Tab>";
          filter = "zn";
          filterr = "zN";
          fzffilter = "zf";
        };
        filter.fzf = {
          action_for = {
            "ctrl-s" = "split";
            "ctrl-t" = "tab drop";
            "ctrl-v" = "vsplit";
            "ctrl-q" = "signtoggle";
          };
          extra_opts = ["--bind" "ctrl-o:toggle-all" "--prompt" "> "];
        };
      };
    };
    highlight = {
      BqfPreviewBorder.fg = "#3e8e2d";
      BqfPreviewTitle.fg = "#3e8e2d";
      BqfPreviewThumb.bg = "#3e8e2d";
      BqfPreviewRange.link = "Search";
    };
  };
}
