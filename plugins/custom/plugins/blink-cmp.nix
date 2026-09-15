{
  programs.nixvim.plugins = {
    friendly-snippets.enable = true;
    blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "default";
          "<CR>" = ["accept" "fallback"];
          "<Tab>" = ["select_next" "snippet_forward" "fallback"];
          "<S-Tab>" = ["select_prev" "snippet_backward" "fallback"];
          "<C-l>" = ["snippet_forward" "fallback"];
          "<C-h>" = ["snippet_backward" "fallback"];
        };
        appearance.nerd_font_variant = "normal";
        completion = {
          list.selection = {
            preselect = true;
            auto_insert = false;
          };
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          accept.auto_brackets.enabled = false;
        };
        signature.enabled = true;
        sources.default = ["lsp" "path" "snippets" "buffer"];
        fuzzy.implementation = "prefer_rust";
      };
    };
  };
}
