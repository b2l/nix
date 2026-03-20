{ pkgs, ... }:

{
  imports = [ ../../common ];

  home = {
    username = "nicolas";
    homeDirectory = "/home/nicolas";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
