{ pkgs, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = "${pkgs.bashInteractive}/bin/bash";
        font = "FiraCode Nerd Font:size=12";
        font-bold = "FiraCode Nerd Font:style=Bold:size=12";
        pad = "20x20";
      };
      scrollback = {
        indicator-position = "fixed";
        indicator-format = "percentage";
      };
    };
  };
}
