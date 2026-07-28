{ config, lib, pkgs, ... }:
let
  paneMenu = pkgs.writeShellScript "tmux-pane-menu" ''
    args=()

    # Windows in the current session
    while IFS=$'\t' read -r idx name; do
      args+=("#$idx: $name" "" "select-window -t $idx")
    done < <(tmux list-windows -F "$(printf '#{window_index}\t#{window_name}')")

    args+=("")

    # Panes across the current session
    while IFS=$'\t' read -r win pane cmd; do
      args+=("$win.$pane: $cmd" "" "select-window -t $win ; select-pane -t $pane")
    done < <(tmux list-panes -s -F "$(printf '#{window_index}\t#{pane_index}\t#{pane_current_command}')")

    tmux display-menu -T "#[align=centre]Windows / Panes" -x C -y C "''${args[@]}"
  '';

  claudePopup = pkgs.writeShellScript "tmux-claude-popup" ''
    session="claude-$1"
    unset TMUX
    tmux new-session -A -s "$session" "direnv exec . claude --continue"
    tmux kill-session -t "$session" 2>/dev/null
  '';

  # display-popup does not format-expand its command argument, so the parent
  # session name is resolved by run-shell and passed in here as positional args.
  claudeLaunch = pkgs.writeShellScript "tmux-claude-launch" ''
    client="$1"
    parent="$2"
    path="$3"
    exec tmux display-popup -c "$client" -E -d "$path" -w 50% -h 50% -x R -y R -S "fg=colour208" "${claudePopup} $parent"
  '';
in
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
        set -as terminal-features 'xterm-kitty:extkeys'
        set -g pane-active-border-style "fg=colour3"
        set -g pane-border-lines heavy
        set -g pane-border-style "fg=colour8"
        set -g renumber-windows on
        set -g status on
        set -g status-justify left
        set -g status-left "#[fg=colour0,bg=#{?client_prefix,colour4,colour3},bold]   "
        set -g status-right "#[fg=colour0,bg=colour4,bold] #S "
        set -g window-status-current-format "#[fg=colour15,bg=colour0,bold] #W:#I:#P#{?window_zoomed_flag, Z,} "
        set -g status-style "bg=colour0,fg=colour15"
        set -g status-left-length 50
        set -g status-position top
        set -g status-right-length 100
        set -g window-status-format ""
        set -g window-status-separator ""
        set -s extended-keys always
        set -g main-pane-width 60%

        bind -n C-Enter   split-window -h -c "#{pane_current_path}" \; select-layout main-vertical
        bind -n C-q       if-shell -F '#{m:claude-*,#{session_name}}' detach-client 'run-shell "${claudeLaunch} #{client_name} #{session_name} #{pane_current_path}"'
        bind -n C-BSpace  resize-pane -Z
        bind -n C-h       select-pane -t :.+
        bind -n C-l       select-pane -t :.-
        bind a            run-shell -b "${paneMenu}"
        bind s            display-popup -E -w 60% -h 50% "tmux list-sessions -F '#{session_name}' | ${pkgs.fzf}/bin/fzf --reverse --prompt 'session> ' | xargs -r tmux switch-client -t"
    '';
  };
}
