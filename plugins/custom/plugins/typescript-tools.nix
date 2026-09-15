{
  programs.nixvim.plugins.typescript-tools = {
    enable = true;
    lazyLoad.settings.ft = [
      "javascript"
      "javascriptreact"
      "typescript"
      "typescriptreact"
    ];
  };
}
