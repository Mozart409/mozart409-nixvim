_: {
  programs.nixvim.plugins.crates = {
    enable = true;
    lazyLoad.settings.event = ["BufRead Cargo.toml"];
    settings = {
      smart_insert = true;
      autoload = true;
      autoupdate = true;
      loading_indicator = true;
      lsp = {
        enabled = true;
        actions = true;
        completion = true;
        hover = true;
      };
    };
  };
  programs.nixvim.autoCmd = [
    {
      event = ["BufRead"];
      pattern = ["Cargo.toml"];
      callback.__raw = ''
        function()
          local crates = require("crates")
          local opts = function(desc)
            return { buffer = true, silent = true, desc = desc }
          end
          vim.keymap.set("n", "<leader>Ct", crates.toggle, opts("Crates: toggle"))
          vim.keymap.set("n", "<leader>Cr", crates.reload, opts("Crates: reload"))
          vim.keymap.set("n", "<leader>Cv", crates.show_versions_popup, opts("Crates: versions popup"))
          vim.keymap.set("n", "<leader>Cf", crates.show_features_popup, opts("Crates: features popup"))
          vim.keymap.set("n", "<leader>Cu", crates.update_crate, opts("Crates: update crate"))
          vim.keymap.set("v", "<leader>Cu", crates.update_crates, opts("Crates: update crates"))
          vim.keymap.set("n", "<leader>CU", crates.upgrade_crate, opts("Crates: upgrade crate"))
          vim.keymap.set("v", "<leader>CU", crates.upgrade_crates, opts("Crates: upgrade crates"))
          vim.keymap.set("n", "<leader>CA", crates.upgrade_all_crates, opts("Crates: upgrade all"))
        end
      '';
    }
  ];
}
