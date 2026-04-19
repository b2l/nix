{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.bashInteractive}/bin/bash";
    mouse = true;
    sensibleOnTop = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    escapeTime = 0;
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
