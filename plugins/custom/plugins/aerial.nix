_: {
  programs.nixvim.plugins.aerial = {
    enable = true;
    lazyLoad.settings.cmd = [
      "AerialToggle"
      "AerialOpen"
      "AerialNavToggle"
      "AerialInfo"
    ];
    settings = {
      backends = ["treesitter" "lsp" "markdown" "asciidoc" "man"];
      layout = {
        max_width = [40 0.2];
        width = null;
        min_width = 10;
        default_direction = "prefer_right";
        placement = "window";
        resize_to_content = true;
        preserve_equality = false;
      };
      attach_mode = "window";
      highlight_on_hover = true;
      highlight_on_jump = 300;
      open_automatic = false;
      show_guides = true;
      filter_kind = false;
      ignore = {
        unlisted_buffers = false;
        diff_windows = true;
        buftypes = "special";
        wintypes = "special";
      };
      manage_folds = false;
      link_folds_to_tree = false;
      link_tree_to_folds = true;
      lsp = {
        diagnostics_trigger_update = true;
        update_when_errors = true;
        update_delay = 300;
      };
      treesitter.update_delay = 300;
    };
  };
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>a";
      action = "<cmd>AerialToggle!<CR>";
      options.desc = "[A]erial symbols toggle";
    }
  ];
}
