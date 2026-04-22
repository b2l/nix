{ ... }:

{
  imports = [ ../../common ];

  home = {
    username = "nicolas";
    homeDirectory = "/home/nicolas";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
