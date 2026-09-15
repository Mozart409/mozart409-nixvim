{
  programs.nixvim.plugins.colorizer = {
    enable = true;
    lazyLoad.settings.event = ["BufReadPre" "BufNewFile"];
    settings = {
      filetypes = ["*"];
      user_default_options = {
        RGB = true;
        RRGGBB = true;
        names = true;
        RRGGBBAA = true;
        AARRGGBB = true;
        rgb_fn = true;
        hsl_fn = true;
        css = true;
        css_fn = true;
        mode = "background";
        tailwind = true;
        sass = {
          enable = true;
          parsers = ["css"];
        };
        virtualtext = "■";
        always_update = false;
      };
      buftypes = [];
    };
  };
}
