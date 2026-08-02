{
  programs.nixvim = {
    plugins = {
      oil = {
        enable = true;
        settings = {
          # Don't hijack directory buffers. Otherwise `nvim .` opens Oil at
          # startup, beating neo-tree's netrw hijack (see neo-tree.nix).
          # Oil stays reachable on demand via `-`.
          default_file_explorer = false;
          delete_to_trash = true;
          skip_confirm_for_simple_edits = true;
          use_default_keymaps = true;
          view_options = {
            show_hidden = true;
          };
        };
      };
    };

    # Global launcher: open the parent directory in Oil. Composes with Oil's
    # in-buffer `-` (go up a dir), so repeated `-` walks up the tree.
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
