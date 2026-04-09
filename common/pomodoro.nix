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

  # Hooks. The CLI fires:
  #   start  → on `start` and `repeat`
  #   break  → on `break` (immediately, before the blocking countdown)
  #   stop   → on `cancel`/`clear`/`finish`, and after `break`'s countdown
  # There is no hook for "work timer reached zero" — that case is handled
  # by the waybar custom module poller (scripts/pomodoro.sh).
  #
  # `stop` is ambiguous between break-end and user actions, so we use
  # an `~/.pomodoro/.in-break` marker to disambiguate.
  home.file.".pomodoro/hooks/start" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      export PATH="$HOME/.nix-profile/bin:$PATH"
      notify-send -a Pomodoro -u normal "Pomodoro started" "Time to focus."
    '';
  };

  home.file.".pomodoro/hooks/break" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      export PATH="$HOME/.nix-profile/bin:$PATH"
      touch "$HOME/.pomodoro/.in-break"
      notify-send -a Pomodoro -u normal "Break started" "Step away from the screen."
    '';
  };

  home.file.".pomodoro/hooks/stop" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      export PATH="$HOME/.nix-profile/bin:$PATH"
      if [[ -f "$HOME/.pomodoro/.in-break" ]]; then
          rm -f "$HOME/.pomodoro/.in-break"
          notify-send -a Pomodoro -u normal "Break ended" "Back to work."
      fi
    '';
  };
}
