{ config, pkgs, ... }:

{
  home.packages = [ pkgs.neovim ];

  home.sessionVariables.EDITOR = "nvim";

  # Mutable symlink so lazy.nvim can write (plugin installs, lazy-lock.json)
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Perso/nix/nvim";
}
