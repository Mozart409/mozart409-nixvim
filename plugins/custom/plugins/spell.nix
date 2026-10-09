{pkgs, ...}: {
  programs.nixvim = {
    opts.spelllang = "en,de";

    # Neovim only ships the English spell files and would otherwise try to
    # download German ones at runtime, so pin them in the runtimepath.
    extraFiles = {
      "spell/de.utf-8.spl".source = pkgs.fetchurl {
        url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.spl";
        hash = "sha256-c8cQfqM5hWzb6SHeuSpFk5xN5uucByYdobndGfaDo9E=";
      };
      "spell/de.utf-8.sug".source = pkgs.fetchurl {
        url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.sug";
        hash = "sha256-E9Ds+Shj2J72DNSopesqWhOg6Pm6jRxqvkerqFcUqUg=";
      };
    };
  };
}
