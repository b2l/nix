{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    mouse = true;
    sensibleOnTop = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    escapeTime = 0;
    extraConfig = ''
      # Pass extended/kitty key sequences through to applications (neovim)
      # so that Esc and Alt are disambiguated at the protocol level.
      set -s extended-keys on
      set -as terminal-features ',foot:extkeys'
      set -as terminal-overrides ',foot:RGB'

      # Binds
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."

      bind C-g display-popup \
        -d "#{pane_current_path}" \
        -w 80% \
        -h 80% \
        -E "lazygit"

      bind C-n display-popup \
        -E 'fish -c "read -P \"Session name: \" name; tmux new-session -d -s $name && tmux switch-client -t $name"'

      bind C-j display-popup \
        -E "tmux list-sessions | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')$\" | fzf --reverse | xargs tmux switch-client -t"

      bind -n -N "Goto window 0" M-0 select-window -T -t 0
      bind -n -N "Goto window 1" M-1 select-window -T -t 1
      bind -n -N "Goto window 2" M-2 select-window -T -t 2
      bind -n -N "Goto window 3" M-3 select-window -T -t 3
      bind -n -N "Goto window 4" M-4 select-window -T -t 4
      bind -n -N "Goto window 5" M-5 select-window -T -t 5
      bind -n -N "Goto window 6" M-6 select-window -T -t 6
      bind -n -N "Goto window 7" M-7 select-window -T -t 7
      bind -n -N "Goto window 8" M-8 select-window -T -t 8
      bind -n -N "Goto window 9" M-9 select-window -T -t 9

      bind -n -N "Goto next window" C-Tab next-window
      bind -n -N "Goto prev window" C-S-Tab previous-window

      # Theme
      bg="#12120f"
      bg_dim="#545464"
      fg="#dcd5ac"
      violet="#766b90"
      cyan="#d7e3d8"

      set -g status on
      set -g status-position top
      set -g status-left-length 100
      set -g status-left-style "fg=#{fg}, bg=#{bg}"
      set -g status-style "fg=#{fg},bg=#{bg}"
      set -g status-left "#[fg=#{violet},bold] #S "
      set -g window-status-format "#[fg=#{fg}, bg=#{bg}] #I:#W "
      set -g window-status-current-format "#[fg=#{cyan}]  #[underscore]#I:#W#[nounderscore] "
      set -g status-right ""
    '';
  };
}
