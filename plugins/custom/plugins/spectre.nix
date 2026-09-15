{
  programs.nixvim.plugins.spectre = {
    enable = true;
    lazyLoad.settings = {
      lazy = true;
      cmd = ["Spectre"];
    };
  };
}
