{ pkgs, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = "${pkgs.bashInteractive}/bin/bash";
        font = "Fira Code:size=12";
        font-bold = "Fira Code:style=Bold:size=12";
        pad = "20x20";
      };
      scrollback = {
        indicator-position = "fixed";
        indicator-format = "percentage";
      };
    };
  };
}
