{ config, lib, pkgs, ... }:
{
  config.programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    keyMode = "vi";
    escapeTime = 10;
    historyLimit = 100000;
    terminal = "tmux-256color";
    baseIndex = 1;
    aggressiveResize = true;
    plugins = with pkgs.tmuxPlugins; [ sensible yank ];

    extraConfig = ''
        set -g status on
        set -g status-position bottom
        set -g status-justify left
        set -g status-style "bg=colour0,fg=colour15"
        set -g status-left-length 50
        set -g status-right-length 100
        set -g status-left "#[fg=colour0,bg=colour3,bold] #{?client_prefix,N,I} "
        set -g window-status-current-format "#[fg=colour15,bg=colour0,bold] #W:#I:#P "
        set -g window-status-format ""
        set -g window-status-separator ""
        set -g status-right "#[fg=colour0,bg=colour4,bold] #S "
        set -g pane-border-style "fg=colour8"
        set -g pane-active-border-style "fg=colour3"
        set -g pane-border-lines heavy
        set -s extended-keys always
        set -as terminal-features 'xterm-kitty:extkeys'

        bind -n C-Enter   split-window -fh -c "#{pane_current_path}"
        bind -n C-q       split-window -h -c "#{pane_current_path}" "bash -c 'direnv exec . claude'"
        bind -n C-BSpace  resize-pane -Z
        bind -n C-h       select-pane -t :.+
        bind -n C-l       select-pane -t :.-
    '';
  };
}
