{
  programs.nixvim = {
    plugins.oil = {
      enable = true;
      lazyLoad.settings.cmd = ["Oil"];
      settings = {
        default_file_explorer = false;
        delete_to_trash = true;
        skip_confirm_for_simple_edits = true;
        use_default_keymaps = true;
        view_options.show_hidden = true;
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "-";
        action = "<CMD>Oil<CR>";
        options = {
          desc = "Open parent directory (Oil)";
          silent = true;
        };
      }
    ];
  };
}
