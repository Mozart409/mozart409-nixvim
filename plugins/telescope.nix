{
  programs.nixvim = {
    # Fuzzy Finder (files, lsp, etc)
    # https://nix-community.github.io/nixvim/plugins/telescope/index.html
    plugins.telescope = {
      # Telescope is a fuzzy finder that comes with a lot of different things that
      # it can fuzzy find! It's more than just a "file finder", it can search
      # many different aspects of Neovim, your workspace, LSP, and more!
      #
      # The easiest way to use Telescope, is to start by doing something like:
      #  :Telescope help_tags
      #
      # After running this command, a window will open up and you're able to
      # type in the prompt window. You'll see a list of `help_tags` options and
      # a corresponding preview of the help.
      #
      # Two important keymaps to use while in Telescope are:
      #  - Insert mode: <c-/>
      #  - Normal mode: ?
      #
      # This opens a window that shows you all of the keymaps for the current
      # Telescope picker. This is really useful to discover what Telescope can
      # do as well as how to actually do it!
      #
      # [[ Configure Telescope ]]
      # See `:help telescope` and `:help telescope.setup()`
      enable = true;

      # Enable Telescope extensions
      extensions = {
        # keep-sorted start
        fzf-native.enable = true;
        ui-select.enable = true;
        # keep-sorted end
      };

      # You can put your default mappings / updates / etc. in here
      #  See `:help telescope.builtin`
      #
      # NOTE: All <leader>s* search mappings are handled by snacks.picker now
      # (see plugins/custom/plugins/snacks.nix). Telescope's cold open would
      # sometimes land the cursor on line 1 of a freshly loaded file instead of
      # the match (treesitter/LSP attach racing the cursor set); snacks' picker
      # doesn't hit that race. The original Telescope mappings are kept below,
      # commented out, in case you want to switch back. Telescope stays enabled
      # for its ui-select extension (vim.ui.select).
      /*
      keymaps = {
        "<leader>sh" = {
          mode = "n";
          action = "help_tags";
          options = {
            desc = "[S]earch [H]elp";
          };
        };
        "<leader>sk" = {
          mode = "n";
          action = "keymaps";
          options = {
            desc = "[S]earch [K]eymaps";
          };
        };
        "<leader>sf" = {
          mode = "n";
          action = "find_files";
          options = {
            desc = "[S]earch [F]iles";
          };
        };
        "<leader>ss" = {
          mode = "n";
          action = "builtin";
          options = {
            desc = "[S]earch [S]elect Telescope";
          };
        };
        "<leader>sw" = {
          mode = "n";
          action = "grep_string";
          options = {
            desc = "[S]earch current [W]ord";
          };
        };
        # NOTE: <leader>sg (live grep) is handled by snacks.picker instead of
        # Telescope — see plugins/custom/plugins/snacks.nix. Telescope's cold
        # open would sometimes land the cursor on line 1 of a fresh file
        # instead of the grep match; snacks' picker avoids that race.
        "<leader>sd" = {
          mode = "n";
          action = "diagnostics";
          options = {
            desc = "[S]earch [D]iagnostics";
          };
        };
        "<leader>sr" = {
          mode = "n";
          action = "resume";
          options = {
            desc = "[S]earch [R]esume";
          };
        };
        "<leader>s." = {
          mode = "n";
          action = "oldfiles";
          options = {
            desc = "[S]earch Recent Files";
          };
        };
        "<leader><leader>" = {
          mode = "n";
          action = "buffers";
          options = {
            desc = "[ ] Find existing buffers";
          };
        };
      };
      */
      settings = {
        extensions.__raw = "{ ['ui-select'] = { require('telescope.themes').get_dropdown() } }";
      };
    };

    # https://nix-community.github.io/nixvim/keymaps/index.html
    # NOTE: These search mappings now live in snacks.picker too (see
    # plugins/custom/plugins/snacks.nix); the Telescope versions are kept
    # commented out below in case you want to switch back.
    keymaps = [
      /*
      # Slightly advanced example of overriding default behavior and theme
      {
        mode = "n";
        key = "<leader>/";
        # You can pass additional configuration to Telescope to change the theme, layout, etc.
        action.__raw = ''
          function()
            require('telescope.builtin').current_buffer_fuzzy_find(
              require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false
              }
            )
          end
        '';
        options = {
          desc = "[/] Fuzzily search in current buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>s/";
        # It's also possible to pass additional configuration options.
        #  See `:help telescope.builtin.live_grep()` for information about particular keys
        action.__raw = ''
          function()
            require('telescope.builtin').live_grep {
              grep_open_files = true,
              prompt_title = 'Live Grep in Open Files'
            }
          end
        '';
        options = {
          desc = "[S]earch [/] in Open Files";
        };
      }
      # Shortcut for searching your Neovim configuration files
      {
        mode = "n";
        key = "<leader>sn";
        action.__raw = ''
          function()
            require('telescope.builtin').find_files {
              cwd = vim.fn.stdpath 'config'
            }
          end
        '';
        options = {
          desc = "[S]earch [N]eovim files";
        };
      }
      */
    ];
  };
}
