{pkgs, ...}: {
  programs.nixvim = {
    extraPackages = with pkgs; [
      # keep-sorted start
      gotools
      # keep-sorted end
    ];

    plugins.fidget = {
      enable = true;
      lazyLoad.settings.event = ["LspAttach"];
    };

    autoGroups = {
      "kickstart-lsp-attach".clear = true;
    };

    plugins.lsp = {
      enable = true;
      servers = {
        clangd.enable = true;
        gopls.enable = true;
        pyright.enable = true;
        bashls.enable = true;
        cue.enable = true;
        dprint.enable = true;
        html.enable = true;
        htmx = {
          enable = true;
          filetypes = ["html" "templ"];
        };
        biome.enable = true;
        yamlls.enable = true;
        cssls.enable = true;
        marksman.enable = true;
        nil_ls.enable = true;
        postgres_lsp.enable = true;
        protols.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        elixirls.enable = false;
        just.enable = true;
        tofu_ls.enable = true;
        csharp_ls.enable = false;
        lua_ls = {
          enable = true;
          settings = {
            completion.callSnippet = "Replace";
            diagnostics.disable = ["missing-fields"];
          };
        };
      };
      keymaps = {
        diagnostic = {
          "<leader>q" = {
            action = "setloclist";
            desc = "Open diagnostic [Q]uickfix list";
          };
        };
        extra = [
          {
            mode = "n";
            key = "gd";
            action.__raw = "function() require('snacks').picker.lsp_definitions() end";
            options.desc = "LSP: [G]oto [D]efinition";
          }
          {
            mode = "n";
            key = "grr";
            action.__raw = "function() require('snacks').picker.lsp_references() end";
            options.desc = "LSP: [G]oto [R]eferences";
          }
          {
            mode = "n";
            key = "gri";
            action.__raw = "function() require('snacks').picker.lsp_implementations() end";
            options.desc = "LSP: [G]oto [I]mplementation";
          }
          {
            mode = "n";
            key = "grt";
            action.__raw = "function() require('snacks').picker.lsp_type_definitions() end";
            options.desc = "LSP: Goto [T]ype definition";
          }
          {
            mode = "n";
            key = "gO";
            action.__raw = "function() require('snacks').picker.lsp_symbols() end";
            options.desc = "LSP: Document symbols";
          }
          {
            mode = "n";
            key = "<leader>D";
            action.__raw = "function() require('snacks').picker.lsp_type_definitions() end";
            options.desc = "LSP: Type [D]efinition";
          }
          {
            mode = "n";
            key = "<leader>ds";
            action.__raw = "function() require('snacks').picker.lsp_symbols() end";
            options.desc = "LSP: [D]ocument [S]ymbols";
          }
          {
            mode = "n";
            key = "<leader>ws";
            action.__raw = "function() require('snacks').picker.lsp_workspace_symbols() end";
            options.desc = "LSP: [W]orkspace [S]ymbols";
          }
        ];
        lspBuf = {
          "<leader>ca" = {
            action = "code_action";
            desc = "LSP: [C]ode [A]ction";
          };
          "gra" = {
            action = "code_action";
            desc = "LSP: Code [A]ction";
          };
          "gD" = {
            action = "declaration";
            desc = "LSP: [G]oto [D]eclaration";
          };
        };
      };
      onAttach = ''
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = bufnr,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = bufnr,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      '';
    };
  };
}
