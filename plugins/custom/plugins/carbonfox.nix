{...}: {
  programs.nixvim = {
    colorschemes.nightfox = {
      enable = true;
      flavor = "carbonfox";
      settings = {
        options = {
          transparent = true;
          terminal_colors = true;
          styles = {
            comments = "italic";
          };
        };
      };
    };
  };
}
