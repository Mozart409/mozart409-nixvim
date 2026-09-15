{pkgs, ...}: {
  programs.nixvim = {
    extraPackages = with pkgs; [
      # keep-sorted start
      gotools
      # keep-sorted end
    ];

    plugins.lspconfig.enable = true;

    plugins.fidget = {
      enable = true;
      lazyLoad.settings.event = ["LspAttach"];
    };

    lsp = {
      inlayHints.enable = false;

      servers = {
        "*".config.capabilities.__raw = "require('blink.cmp').get_lsp_capabilities()";

        bashls.enable = true;
        biome.enable = true;
        clangd.enable = true;
        csharp_ls.enable = false;
        cssls.enable = true;
        cue.enable = true;
        elixirls.enable = false;
        gopls.enable = true;
        html.enable = true;
        htmx = {
          enable = true;
          config.filetypes = ["html" "templ"];
        };
        jsonls.enable = true;
        just.enable = true;
        lua_ls = {
          enable = true;
          config.settings.Lua = {
            completion.callSnippet = "Replace";
            diagnostics.disable = ["missing-fields"];
          };
        };
        marksman.enable = true;
        nil_ls.enable = true;
        postgres_lsp.enable = true;
        protols.enable = true;
        pyright.enable = true;
        rust_analyzer = {
          enable = true;
          packageFallback = true;
        };
        tofu_ls.enable = true;
        yamlls.enable = true;
      };

      keymaps = [
        {
          key = "<leader>q";
          action.__raw = "vim.diagnostic.setloclist";
          options.desc = "Open diagnostic [Q]uickfix list";
        }
        {
          key = "gd";
          action.__raw = "function() require('snacks').picker.lsp_definitions() end";
          options.desc = "LSP: [G]oto [D]efinition";
        }
        {
          key = "gD";
          lspBufAction = "declaration";
          options.desc = "LSP: [G]oto [D]eclaration";
        }
        {
          key = "grr";
          action.__raw = "function() require('snacks').picker.lsp_references() end";
          options.desc = "LSP: [G]oto [R]eferences";
        }
        {
          key = "gri";
          action.__raw = "function() require('snacks').picker.lsp_implementations() end";
          options.desc = "LSP: [G]oto [I]mplementation";
        }
        {
          key = "grt";
          action.__raw = "function() require('snacks').picker.lsp_type_definitions() end";
          options.desc = "LSP: Goto [T]ype definition";
        }
        {
          key = "gO";
          action.__raw = "function() require('snacks').picker.lsp_symbols() end";
          options.desc = "LSP: Document symbols";
        }
        {
          key = "gra";
          lspBufAction = "code_action";
          options.desc = "LSP: Code [A]ction";
        }
        {
          key = "<leader>ca";
          lspBufAction = "code_action";
          options.desc = "LSP: [C]ode [A]ction";
        }
        {
          key = "<leader>D";
          action.__raw = "function() require('snacks').picker.lsp_type_definitions() end";
          options.desc = "LSP: Type [D]efinition";
        }
        {
          key = "<leader>ds";
          action.__raw = "function() require('snacks').picker.lsp_symbols() end";
          options.desc = "LSP: [D]ocument [S]ymbols";
        }
        {
          key = "<leader>ws";
          action.__raw = "function() require('snacks').picker.lsp_workspace_symbols() end";
          options.desc = "LSP: [W]orkspace [S]ymbols";
        }
      ];

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
