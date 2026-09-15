{pkgs, ...}: {
  imports = [
    # keep-sorted start block=yes
    ./plugins/conform.nix
    ./plugins/custom/plugins/aerial.nix
    ./plugins/custom/plugins/autocommands.nix
    ./plugins/custom/plugins/blink-cmp.nix
    ./plugins/custom/plugins/crates.nix
    ./plugins/custom/plugins/d2.nix
    ./plugins/custom/plugins/flash.nix
    ./plugins/custom/plugins/heirline.nix
    ./plugins/custom/plugins/inc-rename.nix
    ./plugins/custom/plugins/lz-n.nix
    ./plugins/custom/plugins/neogen.nix
    ./plugins/custom/plugins/neogit.nix
    ./plugins/custom/plugins/neoscroll.nix
    ./plugins/custom/plugins/nvim-bqf.nix
    ./plugins/custom/plugins/nvim-colorizer.nix
    ./plugins/custom/plugins/nvim-navic.nix
    ./plugins/custom/plugins/oil.nix
    ./plugins/custom/plugins/precognition.nix
    ./plugins/custom/plugins/snacks.nix
    ./plugins/custom/plugins/spectre.nix
    ./plugins/custom/plugins/todo-comments.nix
    ./plugins/custom/plugins/trouble.nix
    ./plugins/custom/plugins/typescript-tools.nix
    ./plugins/custom/plugins/vague.nix
    ./plugins/gitsigns.nix
    ./plugins/kickstart/plugins/autopairs.nix
    ./plugins/kickstart/plugins/indent-blankline.nix
    ./plugins/kickstart/plugins/lint.nix
    ./plugins/kickstart/plugins/neo-tree.nix
    ./plugins/lsp.nix
    ./plugins/treesitter.nix
    ./plugins/which-key.nix
    # keep-sorted end
  ];

  /*
  =====================================================================
  ==================== READ THIS BEFORE CONTINUING ====================
  =====================================================================
  ========                                    .-----.          ========
  ========         .----------------------.   | === |          ========
  ========         |.-""""""""""""""""""-.|   |-----|          ========
  ========         ||                    ||   | === |          ========
  ========         ||  KICKSTART.NIXVIM  ||   |-----|          ========
  ========         ||                    ||   | === |          ========
  ========         ||                    ||   |-----|          ========
  ========         ||:Tutor              ||   |:::::|          ========
  ========         |'-..................-'|   |____o|          ========
  ========         `"")----------------(""`   ___________      ========
  ========        /::::::::::|  |::::::::::\  \ no mouse \     ========
  ========       /:::========|  |==hjkl==:::\  \ required \    ========
  ========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
  ========                                                     ========
  =====================================================================
  =====================================================================
  */
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    withRuby = false;

    performance.byteCompileLua.enable = true;
    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim
    ];

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      have_nerd_font = true;
    };

    clipboard = {
      providers = {
        wl-copy.enable = true;
        xsel.enable = true;
      };
      register = "unnamedplus";
    };

    opts = {
      number = true;
      relativenumber = true;
      mouse = "a";
      showmode = false;
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      list = true;
      listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
      expandtab = true;
      shiftwidth = 2;
      smartindent = true;
      tabstop = 2;
      termguicolors = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Diagnostics (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xX";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        options.desc = "Buffer Diagnostics (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>cs";
        action = "<cmd>Trouble symbols toggle focus=false<cr>";
        options.desc = "Symbols (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xL";
        action = "<cmd>Trouble loclist toggle<cr>";
        options.desc = "Location List (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xQ";
        action = "<cmd>Trouble qflist toggle<cr>";
        options.desc = "Quickfix List (Trouble)";
      }
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
      }
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\><C-n>";
        options.desc = "Exit terminal mode";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w><C-h>";
        options.desc = "Move focus to the left window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w><C-l>";
        options.desc = "Move focus to the right window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w><C-j>";
        options.desc = "Move focus to the lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w><C-k>";
        options.desc = "Move focus to the upper window";
      }
      {
        mode = "n";
        key = "<leader>S";
        action = "<cmd>lua require(\"spectre\").open_visual({select_word=true})<CR>";
        options.desc = "Open Spectre";
      }
    ];

    autoGroups = {
      kickstart-highlight-yank.clear = true;
    };

    autoCmd = [
      {
        event = ["TextYankPost"];
        desc = "Highlight when yanking (copying) text";
        group = "kickstart-highlight-yank";
        callback.__raw = ''
          function()
            vim.hl.on_yank()
          end
        '';
      }
    ];

    plugins = {
      sleuth.enable = true;
      web-devicons.enable = true;
    };
  };
}
