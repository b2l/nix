{ pkgs, ... }:

{
  xdg.portal.config.common.default = "*";

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    systemd.enable = false;

    settings = {
      # Catppuccin Mocha
      "$base" = "rgb(1e1e2e)";
      "$mantle" = "rgb(181825)";
      "$crust" = "rgb(11111b)";
      "$text" = "rgb(cdd6f4)";
      "$subtext0" = "rgb(a6adc8)";
      "$subtext1" = "rgb(bac2de)";
      "$surface0" = "rgb(313244)";
      "$surface1" = "rgb(45475a)";
      "$surface2" = "rgb(585b70)";
      "$overlay0" = "rgb(6c7086)";
      "$overlay1" = "rgb(7f849c)";
      "$overlay2" = "rgb(9399b2)";
      "$blue" = "rgb(89b4fa)";
      "$lavender" = "rgb(b4befe)";
      "$sapphire" = "rgb(74c7ec)";
      "$sky" = "rgb(89dceb)";
      "$teal" = "rgb(94e2d5)";
      "$green" = "rgb(a6e3a1)";
      "$yellow" = "rgb(f9e2af)";
      "$peach" = "rgb(fab387)";
      "$maroon" = "rgb(eba0ac)";
      "$red" = "rgb(f38ba8)";
      "$mauve" = "rgb(cba6f7)";
      "$pink" = "rgb(f5c2e7)";
      "$flamingo" = "rgb(f2cdcd)";
      "$rosewater" = "rgb(f5e0dc)";

      exec-once = [
        "systemctl --user start hyprpolkitagent"
        "udiskie & hyprpaper & hypridle & waybar & wl-paste --type text --watch cliphist store"
        "wl-paste --watch wl-copy --primary"
        "dunst"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];

      exec = [ "lid.sh" ];

      env = [
        "XCURSOR_SIZE,24"
        "GDK_BACKEND,wayland,x11"
        "QT_QPA_PLATFORM,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "SHELL,${pkgs.bashInteractive}/bin/bash"
      ];

      monitor = [
        ", preferred, auto, auto"
        "desc:Samsung Electric Company SyncMaster, 1920x1080@60, auto, 1"
      ];

      input = {
        kb_layout = "us,fr";
        kb_variant = "dvorak-alt-intl,";
        kb_options = "grp:alt_shift_toggle,compose:menu,caps:ctrl_modifier";
        follow_mouse = 0;
        touchpad.natural_scroll = true;
        sensitivity = 0;
      };

      general = {
        gaps_in = 6;
        gaps_out = 10;
        border_size = 3;
        "col.active_border" = "$lavender";
        "col.inactive_border" = "$mantle";
        layout = "dwindle";
      };

      decoration = {
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        fullscreen_opacity = 1;
        rounding = 6;
        blur = {
          enabled = true;
          size = 4;
          passes = 4;
          vibrancy = 0.1696;
          ignore_opacity = false;
        };
      };

      group = {
        "col.border_active" = "$lavender";
        "col.border_inactive" = "$mantle";
        groupbar = {
          text_color_inactive = "$text";
          "col.active" = "$lavender";
          "col.inactive" = "$surface2";
          font_size = 16;
          height = 20;
        };
      };

      animations = {
        enabled = true;
        bezier = [ "md3_decel, 0.05, 0.7, 0.1, 1" ];
        animation = [
          "windowsIn, 1, 6, md3_decel, slide"
          "windowsOut, 1, 6, md3_decel, slide"
          "windowsMove, 1, 6, md3_decel, slide"
          "fade, 1, 10, md3_decel"
          "workspaces, 1, 7, md3_decel, slide"
          "specialWorkspace, 1, 8, md3_decel, slide"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master.new_status = "master";

      misc = {
        vfr = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        font_family = "Open Sans";
      };

      binds.allow_workspace_cycles = true;

      "$mainMod" = "SUPER";
      "$left" = "h";
      "$right" = "l";
      "$up" = "t";
      "$down" = "n";

      bind = [
        "$mainMod SHIFT CTRL, W, exec, start_work.sh"
        "$mainMod, Q, killactive,"
        "$mainMod, RETURN, exec, $TERMINAL"
        "$mainMod, SPACE, exec, rofi -show drun -show-icons"
        "$mainMod CONTROL, SPACE, exec, rofi -show run"
        "$mainMod, E, exec, $TERMINAL lfo"
        "$mainMod, w, togglegroup"
        "$mainMod SHIFT, F, togglefloating,"
        "$mainMod, F, fullscreen,"
        "$mainMod SHIFT, E, exec, tofi-emoji"
        "$mainMod SHIFT, C, exec, hyprpicker -a"
        "$mainMod SHIFT, V, exec, tofi-clip"
        "$mainMod, B, exec, pass-menu bw"
        "$mainMod SHIFT, B, exec, pass-menu pb"
        "$mainMod, T, exec, pomodoro-menu.sh"
        "$mainMod, X, exec, powermenu"
        "$mainMod CONTROL, ESCAPE, exec, pkill waybar; waybar & disown"

        # Media
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86Messenger, exec, playerctl previous"
        ", XF86Go, exec, playerctl play-pause"
        ", Cancel, exec, playerctl next"
        ", XF86AudioMute, exec, volume mute"

        # Screenshots
        "$mainMod SHIFT CTRL, p, exec, grimblast --notify copysave screen"
        "$mainMod SHIFT, p, exec, grimblast --notify copysave area"
        "$mainMod, p, exec, dunstctl set-paused toggle"

        # Focus
        "$mainMod, $left, movefocus, l"
        "$mainMod, $right, movefocus, r"
        "$mainMod, $up, movefocus, u"
        "$mainMod, $down, movefocus, d"
        "$mainMod, TAB, changegroupactive, f"
        "$mainMod+SHIFT, TAB, changegroupactive, b"

        # Move windows
        "$mainMod SHIFT, $left, movewindoworgroup, l"
        "$mainMod SHIFT, $right, movewindoworgroup, r"
        "$mainMod SHIFT, $up, movewindoworgroup, u"
        "$mainMod SHIFT, $down, movewindoworgroup, d"

        # Center
        "$mainMod, c, centerwindow"

        # Workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        "CTRL $mainMod, h, movecurrentworkspacetomonitor, l"
        "CTRL $mainMod, l, movecurrentworkspacetomonitor, r"

        # Special workspace
        "$mainMod, ESCAPE, togglespecialworkspace, magic"
        "$mainMod SHIFT, ESCAPE, movetoworkspace, special:magic"

        # Mouse scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      binde = [
        ", XF86MonBrightnessUp, exec, backlight up"
        ", XF86MonBrightnessDown, exec, backlight down"
        ", XF86AudioRaiseVolume, exec, volume up"
        ", XF86AudioLowerVolume, exec, volume down"
        "$mainMod CONTROL, $left, resizeactive, -40 0"
        "$mainMod CONTROL, $right, resizeactive, 40 0"
        "$mainMod CONTROL, $up, resizeactive, 0 -40"
        "$mainMod CONTROL, $down, resizeactive, 0 40"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindoworgroup"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        ", switch:off:Lid Switch, exec, lid.sh open"
        ", switch:on:Lid Switch, exec, lid.sh close"
      ];

      bindirt = [ ", Caps_Lock, exec, pkill -SIGRTMIN+1 waybar" ];

      layerrule = [
        "blur, launcher"
        "blur, rofi"
        "blur, waybar"
        "ignorezero, waybar"
        "blur, logout_dialog"
      ];
    };
  };

  # Theme files (native format, extracted)
  xdg.configFile = {
    "hypr/hypridle.conf".source = ./theme/hypridle.conf;
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
          "custom/cpu-spark" "custom/sep" "custom/mem-spark"
          "custom/sep" "tray" "pulseaudio" "custom/sep" "network"
          "custom/sep" "battery" "custom/sep" "power-profiles-daemon"
          "custom/sep" "custom/donotdisturb"
          "custom/sep" "hyprland/language" "custom/sep" "custom/power"
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
