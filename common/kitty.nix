{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };
    settings = {
      # Match foot's 20x20 padding.
      window_padding_width = 20;
      scrollback_lines = 10000;
      # Keep kitty's own tabs/splits available without clobbering shell keys.
      confirm_os_window_close = 0;
    };
  };
}
