{
  programs.nixvim.plugins.which-key = {
    enable = true;
    settings.spec = [
      {
        __unkeyed-1 = "<leader>c";
        group = "[C]ode";
      }
      {
        __unkeyed-1 = "<leader>C";
        group = "[C]rates";
      }
      {
        __unkeyed-1 = "<leader>d";
        group = "[D]ocument";
      }
      {
        __unkeyed-1 = "<leader>f";
        group = "[F]ile";
      }
      {
        __unkeyed-1 = "<leader>h";
        group = "Git [H]unk";
        mode = ["n" "v"];
      }
      {
        __unkeyed-1 = "<leader>l";
        group = "[L]azygit";
      }
      {
        __unkeyed-1 = "<leader>n";
        group = "[N]eogen";
      }
      {
        __unkeyed-1 = "<leader>r";
        group = "[R]ename";
      }
      {
        __unkeyed-1 = "<leader>s";
        group = "[S]earch";
      }
      {
        __unkeyed-1 = "<leader>t";
        group = "[T]oggle";
      }
      {
        __unkeyed-1 = "<leader>u";
        group = "[U]tility";
      }
      {
        __unkeyed-1 = "<leader>w";
        group = "[W]orkspace";
      }
      {
        __unkeyed-1 = "<leader>x";
        group = "Diagnostics / Lists";
      }
    ];
  };
}
