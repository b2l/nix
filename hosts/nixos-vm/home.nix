{ ... }:

{
  imports = [ ../../common ];

  home = {
    username = "nicolas";
    homeDirectory = "/home/nicolas";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
