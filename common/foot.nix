{ pkgs, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = "${pkgs.fish}/bin/fish";
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
