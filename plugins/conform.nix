{pkgs, ...}: {
  programs.nixvim = {
    extraPackages = with pkgs; [
      # keep-sorted start
      alejandra
      biome
      clang-tools
      d2
      dprint
      fixjson
      opentofu
      pgformatter
      ruff
      shfmt
      stylua
      yamlfmt
      # keep-sorted end
    ];
    plugins.conform-nvim = {
      enable = true;
      lazyLoad.settings = {
        event = ["BufWritePre"];
        cmd = ["ConformInfo"];
      };
      settings = {
        notify_on_error = false;
        format_on_save = ''
          function(bufnr)
            local disable_filetypes = { c = true, cpp = true }
            return {
              timeout_ms = 500,
              lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and "never" or "fallback",
            }
          end
        '';
        formatters_by_ft = {
          lua = ["stylua"];
          d2 = ["d2"];
          python = ["ruff"];
          json = ["fixjson"];
          jsonc = ["biome"];
          javascript = ["biome"];
          typescript = ["biome"];
          javascriptreact = ["biome"];
          typescriptreact = ["biome"];
          css = ["biome"];
          markdown = ["dprint"];
          yaml = ["yamlfmt"];
          sh = ["shfmt"];
          bash = ["shfmt"];
          go = ["goimports"];
          rust = ["rustfmt"];
          nix = ["alejandra"];
          terraform = ["tofu_fmt"];
          hcl = ["tofu_fmt"];
          proto = ["clang-format"];
          sql = ["pg_format"];
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>m";
        action.__raw = ''
          function()
            require('conform').format { async = true, lsp_format = "fallback" }
          end
        '';
        options.desc = "For[m]at buffer";
      }
    ];
  };
}
