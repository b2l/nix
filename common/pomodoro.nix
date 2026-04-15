{ pkgs, ... }:

{
  home.packages = [ pkgs.openpomodoro-cli ];

  # Open Pomodoro settings.
  # NB: durations are bare integers (minutes); upstream lib appends "m"
  # internally, so writing "25m" here yields "25mm" and a parse error.
  home.file.".pomodoro/settings".text = ''
    daily_goal=8
    default_pomodoro_duration=25
    default_break_duration=5
  '';

  # Only the `start` hook is wired up. We bypass `pomodoro break` entirely
  # in favour of our own break state file (`~/.pomodoro/.break`), driven
  # from scripts/pomodoro-menu.sh and observed by scripts/pomodoro.sh —
  # this gives us a visible countdown in waybar, which `pomodoro break`
  # cannot provide because it writes no state.
  home.file.".pomodoro/hooks/start" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      export PATH="$HOME/.nix-profile/bin:$PATH"
      notify-send -a Pomodoro -u normal "Pomodoro started" "Time to focus."
    '';
  };
}
