{pkgs, ...}: {
  programs.nixvim = {
    extraPackages = with pkgs; [
      # luajitPackages.magick
      imagemagick_light
      fd
    ];

    # https://nix-community.github.io/nixvim/keymaps/index.html
    #
    # Search mappings moved here from Telescope (see plugins/telescope.nix).
    # Telescope's cold open occasionally jumps to line 1 of a freshly loaded
    # file rather than the match (treesitter/LSP attach racing the cursor set);
    # the snacks picker doesn't hit that race.
    keymaps = [
      {
        mode = "n";
        key = "<leader>sh";
        action.__raw = "function() require('snacks').picker.help() end";
        options = {
          desc = "[S]earch [H]elp";
        };
      }
      {
        mode = "n";
        key = "<leader>sk";
        action.__raw = "function() require('snacks').picker.keymaps() end";
        options = {
          desc = "[S]earch [K]eymaps";
        };
      }
      {
        mode = "n";
        key = "<leader>sf";
        action.__raw = "function() require('snacks').picker.files() end";
        options = {
          desc = "[S]earch [F]iles";
        };
      }
      {
        mode = "n";
        key = "<leader>ss";
        action.__raw = "function() require('snacks').picker.pickers() end";
        options = {
          desc = "[S]earch [S]elect picker";
        };
      }
      {
        mode = "n";
        key = "<leader>sw";
        action.__raw = "function() require('snacks').picker.grep_word() end";
        options = {
          desc = "[S]earch current [W]ord";
        };
      }
      {
        mode = "n";
        key = "<leader>sg";
        action.__raw = "function() require('snacks').picker.grep() end";
        options = {
          desc = "[S]earch by [G]rep";
        };
      }
      {
        mode = "n";
        key = "<leader>sd";
        action.__raw = "function() require('snacks').picker.diagnostics() end";
        options = {
          desc = "[S]earch [D]iagnostics";
        };
      }
      {
        mode = "n";
        key = "<leader>sr";
        action.__raw = "function() require('snacks').picker.resume() end";
        options = {
          desc = "[S]earch [R]esume";
        };
      }
      {
        mode = "n";
        key = "<leader>s.";
        action.__raw = "function() require('snacks').picker.recent() end";
        options = {
          desc = "[S]earch Recent Files";
        };
      }
      {
        mode = "n";
        key = "<leader><leader>";
        action.__raw = "function() require('snacks').picker.buffers() end";
        options = {
          desc = "[ ] Find existing buffers";
        };
      }
      {
        mode = "n";
        key = "<leader>/";
        action.__raw = "function() require('snacks').picker.lines() end";
        options = {
          desc = "[/] Fuzzily search in current buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>s/";
        action.__raw = "function() require('snacks').picker.grep_buffers() end";
        options = {
          desc = "[S]earch [/] in Open Files";
        };
      }
      {
        mode = "n";
        key = "<leader>sn";
        action.__raw = ''
          function()
            require('snacks').picker.files({ cwd = vim.fn.stdpath("config") })
          end
        '';
        options = {
          desc = "[S]earch [N]eovim files";
        };
      }
    ];

    plugins.snacks = {
      enable = true;
      settings = {
        animate = {
          enabled = true;
        };

        bigfile = {
          enabled = true;
        };

        input = {
          enabled = true;
        };

        bufdelete = {
          enabled = true;
        };
        terminal = {
          enabled = true;
        };

        dashboard = {
          # DISABLED in favor of alpha-nvim
          enabled = false;
        };

        explorer = {
          enabled = false;
          replace_netrw = true;
          follow_file = true;
          watch = true;
          finder = "explorer";
          supports_live = true;
        };

        gitbrowse = {
          enabled = true;
        };

        image = {
          enabled = true;
        };

        indent = {
          enabled = true;
        };

        quickfile = {
          enabled = true;
        };

        scroll = {
          enabled = false;
        };

        lazygit = {
          enabled = true;
        };
        notifier = {
          enabled = true;
          timeout = 3000;
        };

        statuscolumn = {
          enabled = true;
        };

        picker = {
          matcher = {
            frecency = true;
            sort_empty = true;
          };

          formatters = {
            file = {
              truncate = 200;
            };
          };

          layout = {
            __raw = ''
              {
                layout = {
                  box = "vertical",
                  backdrop = false,
                  row = -1,
                  width = 0,
                  height = 0,
                  border = "top",
                  title = " {title} {live} {flags}",
                  title_pos = "left",
                  { win = "input", height = 1, border = "bottom" },
                  {
                    box = "horizontal",
                    { win = "list", border = "none", height = 0 },
                    { win = "preview", title = "{preview}", width = 0.3, height = 0, border = "left" },
                  },
                },
              }
            '';
          };
        };
        keys = {};
      };
    };
  };
}
