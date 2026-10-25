{pkgs, ...}: {
  programs.nixvim = {
    extraConfigLuaPre = ''
      vim.g.start_time = vim.uv.hrtime()
    '';

    extraPackages = with pkgs; [
      (imagemagick.override {
        libX11Support = false;
        libXtSupport = false;
        djvulibreSupport = false;
        openexrSupport = false;
      })
      fd
    ];

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
        key = "<leader>st";
        action.__raw = ''
          function()
            -- todo-comments registers this picker source in its setup.
            require('todo-comments')
            require('snacks').picker.todo_comments()
          end
        '';
        options.desc = "[S]earch [T]odo comments";
      }
      {
        mode = "n";
        key = "<leader>lg";
        action.__raw = "function() require('snacks').lazygit() end";
        options.desc = "[L]azy[g]it";
      }
      {
        mode = "n";
        key = "<leader>gl";
        action.__raw = "function() require('snacks').lazygit.log() end";
        options.desc = "[G]it: [l]og (lazygit)";
      }
      {
        mode = "n";
        key = "<leader>gf";
        action.__raw = "function() require('snacks').lazygit.log_file() end";
        options.desc = "[G]it: current [f]ile history (lazygit)";
      }
      {
        mode = ["n" "x"];
        key = "<leader>gb";
        action.__raw = "function() require('snacks').gitbrowse() end";
        options.desc = "[G]it: [b]rowse on remote";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action.__raw = "function() require('snacks').bufdelete() end";
        options.desc = "[B]uffer [d]elete";
      }
      {
        mode = "n";
        key = "<leader>bo";
        action.__raw = "function() require('snacks').bufdelete.other() end";
        options.desc = "[B]uffer delete [o]thers";
      }
      {
        mode = ["n" "t"];
        key = "<C-/>";
        action.__raw = "function() require('snacks').terminal() end";
        options.desc = "Toggle terminal";
      }
      {
        # What most terminals send for <C-/>.
        mode = ["n" "t"];
        key = "<C-_>";
        action.__raw = "function() require('snacks').terminal() end";
        options.desc = "Toggle terminal";
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
          enabled = true;
          preset = {
            header = ''

              ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
              ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
              ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
              ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
              ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
              ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
            '';
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
            {
              __raw = ''
                function()
                  local base = vim.g.start_time or vim.uv.hrtime()
                  local ms = (vim.uv.hrtime() - base) / 1e6
                  return {
                    align = "center",
                    padding = 1,
                    text = {
                      { "⚡ Neovim loaded in ", hl = "footer" },
                      { string.format("%.0f", ms), hl = "special" },
                      { " ms", hl = "footer" },
                    },
                  }
                end
              '';
            }
          ];
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
          enabled = false;
        };

        statuscolumn = {
          enabled = false;
        };

        picker = {
          enabled = true;
          ui_select = true;
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

          win = {
            input.keys = {
              "<Tab>".__raw = ''{ "list_down", mode = { "i", "n" } }'';
              "<S-Tab>".__raw = ''{ "list_up", mode = { "i", "n" } }'';
              "<c-space>".__raw = ''{ "select_and_next", mode = { "i", "n" } }'';
              "<c-s-space>".__raw = ''{ "select_and_prev", mode = { "i", "n" } }'';
            };
            list.keys = {
              "<Tab>".__raw = ''{ "list_down", mode = { "n", "x" } }'';
              "<S-Tab>".__raw = ''{ "list_up", mode = { "n", "x" } }'';
              "<c-space>".__raw = ''{ "select_and_next", mode = { "n", "x" } }'';
              "<c-s-space>".__raw = ''{ "select_and_prev", mode = { "n", "x" } }'';
            };
          };
        };
      };
    };
  };
}
