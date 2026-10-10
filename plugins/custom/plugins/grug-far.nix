{
  programs.nixvim = {
    plugins.grug-far = {
      enable = true;
      lazyLoad.settings.cmd = ["GrugFar" "GrugFarWithin"];
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>S";
        action.__raw = ''
          function()
            require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })
          end
        '';
        options.desc = "[S]earch and replace (grug-far)";
      }
      {
        mode = "x";
        key = "<leader>S";
        action.__raw = "function() require('grug-far').with_visual_selection() end";
        options.desc = "[S]earch and replace selection (grug-far)";
      }
    ];
  };
}
