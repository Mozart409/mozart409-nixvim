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
      trashy
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
      {
        mode = "n";
        key = "<leader>lg";
        action.__raw = "function() require('snacks').lazygit() end";
        options = {
          desc = "[L]azy[G]it";
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
        notifier = {
          enabled = false;
          timeout = 3000;
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
