{
  programs.nixvim.plugins.trouble = {
    enable = true;
    lazyLoad.settings.cmd = ["Trouble"];
    settings = {
      auto_refresh = true;
      focus = true;
    };
  };
}
