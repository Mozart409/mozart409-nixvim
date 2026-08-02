{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.nixvim = {
    extraPackages = with pkgs; [
      gcc15
      # `tree-sitter` CLI — satisfies nvim-treesitter's health check and
      # enables runtime `:TSInstall`. Grammars themselves are built by Nix.
      tree-sitter
    ];

    # Pre-warm treesitter parsers shortly after startup. The first file opened
    # via a picker otherwise triggers a cold, async parse that can race the
    # cursor set and drop you on line 1 instead of the match. Loading the
    # parser objects up front makes that first parse effectively synchronous.
    # Deferred with vim.schedule so it never blocks startup.
    # https://nix-community.github.io/nixvim/NeovimOptions/autoCmd/index.html
    autoCmd = [
      {
        event = ["VimEnter"];
        desc = "Pre-warm treesitter parsers";
        callback.__raw = ''
          function()
            vim.schedule(function()
              local langs = {
                "bash", "c", "css", "go", "html", "javascript", "json",
                "lua", "markdown", "nix", "rust", "sql", "tsx",
                "typescript", "yaml",
              }
              for _, lang in ipairs(langs) do
                pcall(vim.treesitter.language.add, lang)
              end
            end)
          end
        '';
      }
    ];

    # Highlight, edit, and navigate code
    # https://nix-community.github.io/nixvim/plugins/treesitter/index.html
    plugins.treesitter = {
      enable = true;

      # Native Nixvim options for the modern nvim-treesitter `main` branch.
      # (The legacy equivalents under `settings.{highlight,indent}` are upstream
      # nvim-treesitter options and emit deprecation warnings on eval.)
      highlight = {
        enable = true;
        # Some languages depend on vim's regex highlighting system (such as
        # Ruby) for indent rules.
        enableVimSyntax = true;
      };

      indent = {
        enable = true;
        disable = ["ruby"];
      };

      # Grammars are provided by Nix, never by `:TSInstall`/`ensure_installed`.
      # Install every bundled grammar EXCEPT qmljs, whose upstream query files
      # fail `:checkhealth` validation ("ERROR qmljs(queries)"). Filtering it out
      # keeps everything else (latex, vue, svelte, …) available for
      # snacks.image inline rendering while silencing the error.
      grammarPackages =
        builtins.filter
        (g: !(lib.hasInfix "qmljs" g.name))
        config.programs.nixvim.plugins.treesitter.package.allGrammars;

      # There are additional nvim-treesitter modules that you can use to interact
      # with nvim-treesitter. You should go explore a few and see what interests you:
      #
      #    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      #    - Show your current context: https://nix-community.github.io/nixvim/plugins/treesitter-context/index.html
      #    - Treesitter + textobjects: https://nix-community.github.io/nixvim/plugins/treesitter-textobjects/index.html
    };

    plugins.treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "af" = "@function.outer";
            "if" = "@function.inner";
            "ac" = "@class.outer";
            "ic" = "@class.inner";
            "aa" = "@parameter.outer";
            "ia" = "@parameter.inner";
          };
        };

        move = {
          enable = true;
          set_jumps = true;
          goto_next_start = {
            "]m" = "@function.outer";
            "]a" = "@parameter.inner";
          };
          goto_next_end = {
            "]M" = "@function.outer";
            "]A" = "@parameter.inner";
          };
          goto_previous_start = {
            "[m" = "@function.outer";
            "[a" = "@parameter.inner";
          };
          goto_previous_end = {
            "[M" = "@function.outer";
            "[A" = "@parameter.inner";
          };
        };

        swap = {
          enable = true;
          swap_next = {
            ">a" = "@parameter.inner";
          };
          swap_previous = {
            "<a" = "@parameter.inner";
          };
        };
      };
    };
  };
}
