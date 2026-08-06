{pkgs, ...}: {
  programs.nixvim = {
    # Dependencies
    #
    # https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=extraplugins#extrapackages
    extraPackages = with pkgs; [
      # keep-sorted start
      alejandra
      biome
      clang-tools
      d2
      dprint
      fixjson
      go
      pgformatter
      ruff
      rustfmt
      shfmt
      # Used to format Lua code
      stylua
      terraform
      yamlfmt
      # keep-sorted end
    ];

    # Autoformat
    # https://nix-community.github.io/nixvim/plugins/conform-nvim.html
    plugins.conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = false;
        format_on_save = ''
          function(bufnr)
            -- Disable "format_on_save lsp_fallback" for lanuages that don't
            -- have a well standardized coding style. You can add additional
            -- lanuages here or re-enable it for the disabled ones.
            local disable_filetypes = { c = true, cpp = true }
            return {
              timeout_ms = 500,
              lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype]
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
          go = [
            "goimports"
            "gofmt"
          ];
          rust = ["rustfmt"];
          nix = ["alejandra"];
          terraform = ["terraform_fmt"];
          hcl = ["terraform_fmt"];
          proto = ["clang-format"];
          sql = ["pg_format"];
          # " " = [ "trim_whitespace" ];
          # Conform can also run multiple formatters sequentially
          #
          # You can use a sublist to tell conform to run *until* a formatter
          # is found
          # javascript = [ [ "prettierd" "prettier" ] ];
        };
      };
    };

    # https://nix-community.github.io/nixvim/keymaps/index.html
    keymaps = [
      # NOTE: lives under <leader>c, not bare <leader>f. <leader>f is the
      # explorer prefix (<leader>fe); binding format to <leader>f made every
      # format stall for `timeoutlen` while nvim waited to see if an `e`
      # followed. Both are instant now that they don't share a prefix.
      {
        mode = "n";
        key = "<leader>cf";
        action.__raw = ''
          function()
            require('conform').format { async = true, lsp_fallback = true }
          end
        '';
        options = {
          desc = "[C]ode [F]ormat buffer";
        };
      }
    ];
  };
}
