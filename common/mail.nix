{ pkgs, ... }:

{
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    new.tags = [ "unread" "inbox" ];
    # `.mbsyncstate` and `.uidvalidity` are added automatically by programs.mbsync.
    search.excludeTags = [ "deleted" "spam" ];
    maildir.synchronizeFlags = true;
  };

  accounts.email.maildirBasePath = "mail";

  accounts.email.accounts = {
    ling = {
      primary = true;
      realName = "Nicolas Medda";
      address = "nicolas@ling.fr";
      userName = "nicolas@ling.fr";
      passwordCommand = "secret-tool lookup all ling";
      imap = {
        host = "pro3.mail.ovh.net";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "pro3.mail.ovh.net";
        port = 587;
        tls.useStartTls = true;
      };
      folders.inbox = "INBOX";
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        patterns = [
          "*"
          "!Contacts"
          "!Calendrier"
          "!Calendrier/*"
          "!Journal"
          "!Notes"
          ''!"Tâches"''
        ];
        extraConfig.account.AuthMechs = "PLAIN";
      };
      msmtp = {
        enable = true;
        extraConfig.auth = "login";
      };
      notmuch.enable = true;
    };

    cheneetcie = {
      realName = "Nicolas Medda";
      address = "nicolas@cheneetcompagnie.fr";
      userName = "nicolas@cheneetcompagnie.fr";
      passwordCommand = "secret-tool lookup all cheneetcie";
      imap = {
        host = "pro3.mail.ovh.net";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "pro3.mail.ovh.net";
        port = 587;
        tls.useStartTls = true;
      };
      folders.inbox = "INBOX";
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        extraConfig.account.AuthMechs = "PLAIN";
      };
      msmtp = {
        enable = true;
        extraConfig.auth = "login";
      };
      notmuch.enable = true;
    };

    b2l = {
      flavor = "gmail.com";
      realName = "Nicolas Medda";
      address = "b2l.powa@gmail.com";
      userName = "b2l.powa@gmail.com";
      passwordCommand = "secret-tool lookup all b2l";
      smtp.tls.useStartTls = true;
      folders.inbox = "INBOX";
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        patterns = [
          "*"
          "![Gmail]*"
          "[Gmail]/Sent Mail"
          "[Gmail]/Drafts"
          "[Gmail]/Trash"
          "[Gmail]/Spam"
        ];
      };
      msmtp.enable = true;
      notmuch.enable = true;
    };

    lcdp = {
      flavor = "gmail.com";
      realName = "Nicolas Medda";
      address = "nicolas@lecomptoirdespharmacies.fr";
      userName = "nicolas@lecomptoirdespharmacies.fr";
      passwordCommand = "secret-tool lookup all lcdp";
      smtp.tls.useStartTls = true;
      folders.inbox = "INBOX";
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        patterns = [
          "*"
          "![Gmail]*"
          "[Gmail]/Sent Mail"
          "[Gmail]/Drafts"
          "[Gmail]/Trash"
          "[Gmail]/Spam"
        ];
      };
      msmtp.enable = true;
      notmuch.enable = true;
    };
  };

  # libsecret provides `secret-tool`, used by all PassCmd/passwordeval entries above.
  home.packages = [ pkgs.libsecret ];

  # Periodic sync. Using `;` (not `&&`) so notmuch still indexes if mbsync errors
  # on one account — matches the behavior before migration and avoids the
  # all-or-nothing semantics of notmuch's pre-new hook.
  systemd.user.services.mailsync = {
    Unit.Description = "Sync mail and index";
    Service = {
      Type = "oneshot";
      Environment = [
        "PATH=${pkgs.lib.makeBinPath [ pkgs.libsecret ]}"
        "NOTMUCH_CONFIG=%h/.config/notmuch/default/config"
      ];
      ExecStart = "${pkgs.writeShellScript "mailsync" ''
        ${pkgs.isync}/bin/mbsync -a
        ${pkgs.notmuch}/bin/notmuch new
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
