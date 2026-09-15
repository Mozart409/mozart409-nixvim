{
  programs.nixvim = {
    plugins.neogit = {
      enable = true;
      lazyLoad.settings.cmd = ["Neogit"];
      settings = {
        kind = "auto";
        commit_popup.kind = "split";
        integrations = {
          diffview = true;
          snacks = true;
        };
        signs = {
          hunk = ["" ""];
          item = ["" ""];
          section = ["" ""];
        };
      };
    };
    plugins.diffview = {
      enable = true;
      lazyLoad.settings.cmd = [
        "DiffviewOpen"
        "DiffviewClose"
        "DiffviewFileHistory"
        "DiffviewToggleFiles"
        "DiffviewFocusFiles"
        "DiffviewRefresh"
      ];
    };
  };
}
