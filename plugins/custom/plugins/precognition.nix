{
  programs.nixvim = {
    plugins.precognition = {
      enable = true;
      lazyLoad.settings.cmd = ["Precognition"];
      settings = {
        startVisible = false;
        showBlankVirtLine = true;
        highlightColor.link = "Comment";
        hints = {
          Caret = {
            text = "^";
            prio = 2;
          };
          Dollar = {
            text = "$";
            prio = 1;
          };
          MatchingPair = {
            text = "%";
            prio = 5;
          };
          Zero = {
            text = "0";
            prio = 1;
          };
          w = {
            text = "w";
            prio = 10;
          };
          b = {
            text = "b";
            prio = 9;
          };
          e = {
            text = "e";
            prio = 8;
          };
          W = {
            text = "W";
            prio = 7;
          };
          B = {
            text = "B";
            prio = 6;
          };
          E = {
            text = "E";
            prio = 5;
          };
        };
        gutterHints = {
          G = {
            text = "G";
            prio = 10;
          };
          gg = {
            text = "gg";
            prio = 9;
          };
          PrevParagraph = {
            text = "{";
            prio = 8;
          };
          NextParagraph = {
            text = "}";
            prio = 8;
          };
        };
        disabled_fts = [
          "snacks_dashboard"
          "neo-tree"
          "oil"
          "Trouble"
          "trouble"
          "notify"
          "snacks_terminal"
        ];
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>tp";
        action.__raw = ''
          function()
            if require("precognition").toggle() then
              vim.notify("Precognition ON")
            else
              vim.notify("Precognition OFF")
            end
          end
        '';
        options.desc = "[T]oggle [P]recognition";
      }
      {
        mode = "n";
        key = "<leader>up";
        action.__raw = "function() require('precognition').peek() end";
        options.desc = "Precognition Peek";
      }
    ];
  };
}
