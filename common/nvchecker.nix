{ pkgs, ... }:

# nvchecker — daily poll of upstream versions for pinned custom packages and
# the NixOS stable channel. Writes state to ~/.cache/nvchecker/newver.json,
# which the waybar-updates script reads to surface update notices.
#
# Adding a new source:
#   1. Add a block to nvchecker.toml (github / cmd / git / …).
#   2. Teach waybar-updates how to parse its pinned version from the repo.

{
  home.packages = [ pkgs.nvchecker ];

  xdg.configFile."nvchecker/config.toml".source = ./nvchecker.toml;

  systemd.user.services.nvchecker = {
    Unit.Description = "Check upstream versions for pinned packages";
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.cache/nvchecker";
      ExecStart = "${pkgs.nvchecker}/bin/nvchecker -c %h/.config/nvchecker/config.toml";
      # The `cmd` source calls check-nixos-channel (in ~/.local/bin), which
      # needs gh + jq + coreutils. Systemd user services don't inherit the
      # login PATH, so build a minimal one explicitly.
      Environment = "PATH=%h/.local/bin:${pkgs.gh}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin";
    };
  };

  systemd.user.timers.nvchecker = {
    Unit.Description = "Daily upstream-version check";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
