{
  programs.nixvim = {
    plugins = {
      oil = {
        enable = true;
        settings = {
          delete_to_trash = true;
          skip_confirm_for_simple_edits = true;
          use_default_keymaps = true;
          view_options = {
            show_hidden = true;
          };
        };
      };
    };
  };
}
