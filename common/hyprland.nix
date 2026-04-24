{ pkgs, ... }:

{
  xdg.portal.config.common.default = "*";

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    systemd.enable = false;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  # Theme files (native format, extracted)
  xdg.configFile = {
    "hypr/hypridle.conf".source = ./theme/hypridle.conf;
    "hypr/hyprlock.conf".source = ./theme/hyprlock.conf;
    "hypr/hyprpaper.conf".source = ./theme/hyprpaper.conf;
    "tofi/config".source = ./theme/tofi-config;
    "tofi/powermenu-config".source = ./theme/tofi-powermenu;
    "wlogout/layout".source = ./theme/wlogout-layout;
    "wlogout/style.css".text = ''
      * {
          background-image: none;
          box-shadow: none;
          font-family: "Cantarell", sans-serif;
      }
      window {
          background-color: rgba(17, 17, 27, 0.85);
      }
      button {
          background-color: rgba(17, 17, 27, 0.85);
          border: none;
          border-radius: 6px;
          margin: 200px 12px;
          padding-top: 80px;
          color: #6c7086;
          font-size: 12pt;
          background-repeat: no-repeat;
          background-position: center 38%;
          background-size: 40%;
          transition: all 250ms cubic-bezier(0.05, 0.7, 0.1, 1);
          outline-style: none;
      }
      button:hover {
          background-color: rgba(49, 50, 68, 0.95);
          border-color: rgba(203, 166, 247, 0.7);
          box-shadow: 0 0 16px rgba(203, 166, 247, 0.2);
          color: #cdd6f4;
      }
      button:focus {
          background-color: rgba(49, 50, 68, 0.95);
          border-color: rgba(203, 166, 247, 0.5);
          outline-style: none;
      }
      button:active {
          background-color: rgba(69, 71, 90, 0.95);
          border-color: #cba6f7;
      }
      #lock {
          background-image: image(url("${./theme/wlogout-icons/lock.png}"));
      }
      #suspend {
          background-image: image(url("${./theme/wlogout-icons/suspend.png}"));
      }
      #reboot {
          background-image: image(url("${./theme/wlogout-icons/reboot.png}"));
      }
      #shutdown {
          background-image: image(url("${./theme/wlogout-icons/shutdown.png}"));
      }
      #logout {
          background-image: image(url("${./theme/wlogout-icons/logout.png}"));
      }
    '';
  };

  # Waybar
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        name = "mainbar";
        layer = "top";
        position = "top";
        height = 36;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;
        spacing = 6;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" "custom/pomodoro" ];
        modules-right = [
          "custom/cpu-spark" "custom/sep" 
          "custom/mem-spark" "custom/sep" 
          "tray" 
          "pulseaudio" "custom/sep" 
          "network" "custom/sep" 
          "battery" "custom/sep" 
          "power-profiles-daemon" "custom/sep" 
          "custom/donotdisturb" "custom/sep" 
          "custom/updates" "custom/sep" 
          "hyprland/language" "custom/sep" 
          "custom/power"
        ];
        "custom/pomodoro" = {
          format = "{}";
          return-type = "json";
          exec = "pomodoro.sh";
          interval = 1;
        };
        "custom/cpu-spark" = {
          format = "{}";
          return-type = "json";
          exec = "sparkline-cpu.sh";
          interval = 2;
        };
        "custom/mem-spark" = {
          format = "{}";
          return-type = "json";
          exec = "sparkline-mem.sh";
          interval = 5;
        };
        "custom/sep" = { format = " "; tooltip = false; };
        "custom/donotdisturb" = { exec = "donotdisturb.sh"; format = "{}"; interval = 1; return-type = "json"; signal = 1; on-click = "dunstctl set-paused toggle"; };
        "custom/updates" = {
          exec = "waybar-updates";
          format = "{}";
          return-type = "json";
          interval = 3600;
          # nvchecker refreshes state daily; hourly widget poll keeps the
          # displayed text in sync soon after a bump lands on disk.
          on-click = "xdg-open https://nixos.org/manual/nixos/stable/release-notes";
          tooltip = true;
        };
        "hyprland/window".separate-outputs = true;
        "hyprland/workspaces" = { disable-scroll = true; all-outputs = true; on-click = "activate"; };
        tray.spacing = 10;
        "hyprland/language" = { format = "{short}"; };
        clock = { tooltip-format = "{:%A, %B %d, %Y}"; format = "{:%H:%M}"; };
        battery = {
          states = { warning = 20; critical = 10; };
          format = "󱊣 {capacity}";
          format-charging = "󰂄 {capacity}";
          format-full = "󱊣 100";
          tooltip-format = "{timeTo}";
        };
        network = {
          format-wifi = "󰤨 {signalStrength}";
          format-ethernet = "󰛳";
          format-disconnected = "󰤭";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname}: {ipaddr}";
          on-click = "hyprctl dispatch exec '[float]' '$TERMINAL -e networkmanager_dmenu'";
        };
        pulseaudio = {
          format = "󰕾 {volume}";
          format-muted = "󰖁 0";
          tooltip-format = "{desc}";
          on-click = "pavucontrol";
        };
        "custom/power" = { format = "󰐥"; on-click = "sleep 0.15 && powermenu"; };
        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          format-icons = {
            performance = "󰓅";
            balanced = "󰾅";
            power-saver = "󰌪";
          };
        };
      };

      nowPlaying = {
        name = "nowplaying";
        layer = "top";
        position = "bottom";
        height = 34;
        margin-bottom = 8;
        modules-center = [ "mpris" ];
        mpris = {
          format = "{player_icon}  {dynamic}";
          format-paused = "{status_icon}  {dynamic}";
          format-stopped = "";
          player-icons = {
            default = "▶";
            spotify = "󰓇";
            firefox = "󰈹";
            chromium = "󰊯";
          };
          status-icons = {
            paused = "󰏤";
          };
          dynamic-order = [ "title" "artist" ];
          dynamic-separator = "  —  ";
          title-len = 30;
          artist-len = 20;
          tooltip-format = "{player}: {title} — {artist} ({album})";
        };
      };
    };
    style = builtins.readFile ./theme/waybar-style.css;
  };

  # Rofi
  programs.rofi = {
    enable = true;
    font = "JetBrains Mono 14";
    terminal = "foot";
    theme = ./theme/rofi-theme.rasi;
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus";
      drun-display-format = "{name}";
      display-drun = "";
      display-run = "";
      disable-history = false;
      click-to-exit = true;
    };
  };

  # Dunst
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 320;
        origin = "top-right";
        offset = "(14, 52)";
        progress_bar = true;
        progress_bar_height = 6;
        progress_bar_frame_width = 0;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corner_radius = 3;
        indicate_hidden = true;
        shrink = false;
        separator_height = 1;
        separator_color = "#313244";
        padding = 12;
        horizontal_padding = 14;
        frame_width = 3;
        frame_color = "#585b70";
        corner_radius = 6;
        sort = true;
        idle_threshold = 120;
        font = "JetBrains Mono 10";
        line_height = 0;
        markup = "full";
        format = "<span weight='bold' font='11'>%s</span>\\n<span color='#a6adc8'>%b</span>";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        word_wrap = true;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 40;
        enable_recursive_icon_lookup = true;
        icon_theme = "Papirus-Dark";
        sticky_history = true;
        history_length = 20;
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        ignore_dbusclose = false;
        force_xwayland = false;
        force_xinerama = false;
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
      experimental.per_monitor_dpi = false;
      urgency_low = {
        background = "#181825ee";
        foreground = "#cdd6f4";
        highlight = "#89b4fa";
        frame_color = "#45475a";
        timeout = 5;
      };
      urgency_normal = {
        background = "#181825ee";
        foreground = "#cdd6f4";
        highlight = "#b4befe";
        frame_color = "#45475a";
        timeout = 5;
      };
      urgency_critical = {
        background = "#181825ee";
        foreground = "#cdd6f4";
        highlight = "#f38ba8";
        frame_color = "#f38ba8";
        timeout = 1000;
      };
      volume = { appname = "Volume"; highlight = "#cba6f7"; };
      backlight = { appname = "Backlight"; highlight = "#eba0ac"; };
    };
  };
}
