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

  # Spawns claude command in a new pane to the right of the current one
  claudeSpawn = pkgs.writeShellScript "tmux-claude-spawn" ''
    claude
  '';

  # Spawns hermes command in a new pane to the right of the current one
  hermesSpawn = pkgs.writeShellScript "tmux-hermes-spawn" ''
    /home/placek/.local/bin/trismegistos
  '';

  # Menu for spawning claude or hermes in a new pane
  spawnMenu = pkgs.writeShellScript "tmux-spawn-menu" ''
    tmux display-menu -T "#[align=centre]Spawn" -x C -y C \
      "claude" "" "split-window -h -c '#{pane_current_path}' '${claudeSpawn}' ; select-layout main-vertical" \
      "hermes" "" "split-window -h -c '#{pane_current_path}' '${hermesSpawn}' ; select-layout main-vertical"
  '';

  # Runs a single make rule inside a fresh pane and blocks on a keypress so the
  # output (and exit status) stays visible until dismissed.
  makeRun = pkgs.writeShellScript "tmux-make-run" ''
    dir="$1"
    target="$2"
    cd "$dir" || exit 1
    direnv exec "$dir" make "$target"
    status=$?
    printf '\n[make %s exited %s] press any key to close…' "$target" "$status"
    read -rn1 _
  '';

  # Reads the rules from the Makefile in the pane's directory and offers them as
  # a menu; picking one splits a new pane that runs it via makeRun.
  makeMenu = pkgs.writeShellScript "tmux-make-menu" ''
    dir="$1"
    [ -z "$dir" ] && dir="$PWD"
    makefile="$dir/Makefile"
    if [ ! -f "$makefile" ]; then
      tmux display-message "No Makefile in $dir"
      exit 0
    fi

    keys="123456789abcdefghijklmnopqrstuvwxyz"
    i=0
    args=()
    # Ask make itself for its target database (-p) so rules pulled in from
    # included makefiles are listed too, not just those in this Makefile.
    # Run under direnv so the listing matches the directory's environment.
    while IFS= read -r target; do
      key="''${keys:$i:1}"
      args+=("$target" "$key" "split-window -h -c \"$dir\" \"${makeRun} '$dir' '$target'\"")
      i=$((i + 1))
    done < <(direnv exec "$dir" make -C "$dir" -pRrq 2>/dev/null \
      | awk -F: '/^[a-zA-Z0-9][^$#\/\t =%]*:([^=]|$)/ {print $1}' \
      | sort -u \
      | grep -vE '^(Makefile|GNUmakefile|.*\.mk)$')

    tmux display-menu -T "#[align=centre]make" -x C -y C "''${args[@]}"
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
        bind -n C-q       run-shell -b "${spawnMenu}"
        bind -n C-BSpace  resize-pane -Z
        bind -n C-h       select-pane -t :.+
        bind -n C-l       select-pane -t :.-
        bind a            run-shell -b "${paneMenu}"
        bind m            run-shell -b "${makeMenu} #{pane_current_path}"
        bind s            display-popup -E -w 60% -h 50% "tmux list-sessions -F '#{session_name}' | ${pkgs.fzf}/bin/fzf --reverse --prompt 'session> ' | xargs -r tmux switch-client -t"
        bind D display-popup -w 90% -h 90% -E "gh dash"
    '';
  };
}
