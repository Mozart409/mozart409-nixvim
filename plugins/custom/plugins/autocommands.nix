{
  programs.nixvim.autoCmd = [
    {
      event = "FileType";
      pattern = "help";
      command = "wincmd L";
    }
    {
      event = "FileType";
      pattern = [
        "gitcommit"
        "tex"
        "latex"
        "markdown"
      ];
      command = "setlocal spell";
    }
  ];
}
