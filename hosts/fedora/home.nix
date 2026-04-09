{ pkgs, ... }:

{
  imports = [ ../../common ];

  home = {
    username = "nicolas";
    homeDirectory = "/home/nicolas";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  systemd.user.services.mailsync = {
    Unit.Description = "Sync mail and index";
    Service = {
      Type = "oneshot";
      Environment = [ "PATH=${pkgs.lib.makeBinPath [ pkgs.libsecret ]}" ];
      ExecStart = "${pkgs.writeShellScript "mailsync" ''
        ${pkgs.isync}/bin/mbsync -a; ${pkgs.notmuch}/bin/notmuch new
      ''}";
    };
  };

  systemd.user.timers.mailsync = {
    Unit.Description = "Sync mail every minute";
    Timer = {
      OnCalendar = "minutely";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
