{pkgs, ...}: {
  programs.nixvim = {
    extraPackages = with pkgs; [
      # luajitPackages.magick
      imagemagick_light
      fd
      # Provides the `trash` binary snacks uses to move files to trash
      # (silences the health-check warning about trash/gio/kioclient).
      trashy
      # snacks.image doc renderers:
      #   ghostscript -> `gs`      : PDF files
      #   tectonic    -> LaTeX math expressions
      #   mermaid-cli -> `mmdc`    : Mermaid diagrams
      # NOTE: mermaid-cli pulls in chromium (large closure). Drop it if you
      # don't need inline Mermaid rendering.
      ghostscript
      tectonic
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
        # Disabled: cosmetic only, and this config was disabled originally to
        # avoid clashing with the existing indent-blankline / noice setup. We
        # only want snacks.picker, so keep the overlapping bits off.
        animate = {
          enabled = true;
        };

        bigfile = {
          enabled = true;
        };

        # Disabled: noice + dressing already handle vim.ui.input.
        input = {
          enabled = false;
        };

        bufdelete = {
          enabled = true;
        };
        terminal = {
          enabled = true;
        };

        dashboard = {
          enabled = true;
          preset = {
            # Reused from the old alpha.nix banner.
            header = ''

                ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
                ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
                ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
                ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
                ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
                ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
            '';
            # Buttons route through Snacks.dashboard.pick, which uses the
            # snacks picker that's already enabled below.
            keys = [
              {
                icon = " ";
                key = "f";
                desc = "Find File";
                action = ":lua Snacks.dashboard.pick('files')";
              }
              {
                icon = " ";
                key = "n";
                desc = "New File";
                action = ":ene | startinsert";
              }
              {
                icon = " ";
                key = "g";
                desc = "Find Text";
                action = ":lua Snacks.dashboard.pick('live_grep')";
              }
              {
                icon = " ";
                key = "r";
                desc = "Recent Files";
                action = ":lua Snacks.dashboard.pick('oldfiles')";
              }
              {
                icon = " ";
                key = "c";
                desc = "Config";
                action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })";
              }
              {
                icon = " ";
                key = "l";
                desc = "Lazygit";
                action = ":lua Snacks.lazygit()";
              }
              {
                icon = " ";
                key = "q";
                desc = "Quit";
                action = ":qa";
              }
            ];
          };
          sections = [
            {section = "header";}
            {
              section = "keys";
              gap = 1;
              padding = 1;
            }
            {
              section = "recent_files";
              icon = " ";
              title = "Recent Files";
              indent = 2;
              padding = 1;
            }
            {
              section = "projects";
              icon = " ";
              title = "Projects";
              indent = 2;
              padding = 1;
            }
            {section = "startup";}
          ];
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

        # Disabled: indent-blankline already draws indent guides.
        indent = {
          enabled = false;
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
        # Disabled: noice already handles notifications.
        notifier = {
          enabled = false;
          timeout = 3000;
        };

        # Disabled: avoid fighting the existing statuscolumn/sign setup.
        statuscolumn = {
          enabled = false;
        };

        picker = {
          # Point snacks' ffi.load() at the sqlite shared library so frecency
          # and history use SQLite instead of a flat file. On Nix the linker
          # won't find `libsqlite3.so` by name, so pass its absolute path.
          db = {
            sqlite3_path = "${pkgs.sqlite.out}/lib/libsqlite3.so";
          };

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
