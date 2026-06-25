{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.neovim
    # Inline diagram rendering in nvim (image.nvim + diagram.nvim):
    #   - imagemagick: image.nvim's magick_cli processor (sixel conversion)
    #   - mermaid-cli: `mmdc`, renders mermaid code blocks to PNG
    pkgs.imagemagick
    pkgs.mermaid-cli
    # External viewer for "zoom" on a diagram (real pan/zoom; inline image.nvim
    # is a static raster). Bound to <leader>dz in nvim/lua/plugins/image.lua.
    pkgs.imv
  ];

  home.sessionVariables.EDITOR = "nvim";

  # Mutable symlink so lazy.nvim can write (plugin installs, lazy-lock.json)
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Perso/nix/nvim";
}
