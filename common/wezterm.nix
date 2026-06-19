{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    # home-manager prepends `local wezterm = require 'wezterm'`, so this block
    # just builds and returns the config table.
    extraConfig = ''
      local config = wezterm.config_builder()

      -- Catppuccin Mocha via the catppuccin module's injected plugin (themes
      -- the palette AND the fancy tab-bar frame). `catppuccin_plugin` is
      -- defined by catppuccin.wezterm (mkBefore); guard so this degrades
      -- gracefully if that module is ever disabled.
      if catppuccin_plugin then
        dofile(catppuccin_plugin).apply_to_config(config, catppuccin_config)
      end

      -- Shell — match foot/tmux.
      config.default_prog = { '${pkgs.bashInteractive}/bin/bash' }

      -- Appearance (mirrors foot.nix).
      config.font = wezterm.font('FiraCode Nerd Font')
      config.font_size = 12.0
      config.window_padding = { left = 20, right = 20, top = 20, bottom = 20 }
      config.window_decorations = 'NONE'        -- Hyprland draws the frame.
      config.scrollback_lines = 10000

      -- Tab bar at the TOP.
      config.enable_tab_bar = true
      config.tab_bar_at_bottom = false
      config.use_fancy_tab_bar = true
      -- Keep the bar visible even with one tab, so the status is always shown.
      config.hide_tab_bar_if_only_one_tab = false

      -- Status: active workspace ("session") + leader indicator.
      wezterm.on('update-status', function(window, _)
        local ws = window:active_workspace()
        local leader = window:leader_is_active() and ' ⌨ LEADER ' or ''
        window:set_left_status(wezterm.format {
          { Foreground = { Color = '#cba6f7' } },  -- catppuccin mauve
          { Text = '  ' .. ws },
          { Foreground = { Color = '#f9e2af' } },  -- catppuccin yellow
          { Text = leader },
        })
      end)

      -- tmux-style leader: Ctrl+b (same prefix as your tmux).
      config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }

      local act = wezterm.action
      config.keys = {
        -- Tabs (tmux parity: prefix c / & / ,)
        { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
        { key = '&', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab { confirm = true } },
        { key = ',', mods = 'LEADER', action = act.PromptInputLine {
            description = 'Rename tab',
            action = wezterm.action_callback(function(window, _, line)
              if line and line ~= "" then window:active_tab():set_title(line) end
            end),
        } },

        -- Splits (tmux parity: prefix % = side-by-side, " = stacked)
        { key = '%', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = '"', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
        { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
        { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

        -- Workspaces == your "sessions" (tmux parity: switch / new session)
        { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
        { key = 'n', mods = 'LEADER', action = act.PromptInputLine {
            description = 'New workspace name',
            action = wezterm.action_callback(function(window, pane, line)
              if line and line ~= "" then
                window:perform_action(act.SwitchToWorkspace { name = line }, pane)
              end
            end),
        } },
        { key = 'R', mods = 'LEADER|SHIFT', action = act.PromptInputLine {
            description = 'Rename current workspace',
            action = wezterm.action_callback(function(_, _, line)
              if line and line ~= "" then
                wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
              end
            end),
        } },

        -- Directional pane focus — Alt+h/t/n/l (matches your tmux M-h/t/n/l).
        { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
        { key = 't', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
        { key = 'n', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
        { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
      }

      -- Goto tab by index — Alt+0..8 (matches your tmux M-0..8).
      for i = 0, 8 do
        table.insert(config.keys, {
          key = tostring(i),
          mods = 'ALT',
          action = act.ActivateTab(i),
        })
      end

      return config
    '';
  };
}
