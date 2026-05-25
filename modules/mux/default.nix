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
#       =========================================================
#       Mouse — selection / word / line, click-to-focus, no auto-exit on drag end
#       =========================================================
#       set -g mouse on
#       bind-key -T copy-mode-vi MouseDragEnd1Pane  send-keys -X copy-pipe-no-clear
#       bind-key -T copy-mode-vi DoubleClick1Pane   select-pane \; send-keys -X select-word \; send-keys -X copy-pipe-no-clear
#       bind-key -T copy-mode-vi TripleClick1Pane   select-pane \; send-keys -X select-line \; send-keys -X copy-pipe-no-clear
#
#       =========================================================
#       Copy / paste (vi-style in copy-mode, plus prefix shortcuts)
#       =========================================================
#       bind-key -T copy-mode-vi v send-keys -X begin-selection
#       bind-key -T copy-mode-vi y send-keys -X copy-pipe-no-clear
#       bind-key -T copy-mode-vi Y send-keys -X copy-pipe-and-cancel
#
#       prefix + C / V / X  ≈ kitty_mod+shift+{c,v,x}
#       bind-key C copy-mode
#       bind-key V run-shell "tmux set-buffer -- \"$(wl-paste 2>/dev/null || xclip -selection clipboard -o)\"; tmux paste-buffer"
#       bind-key X run-shell "tmux set-buffer -- \"$(wl-paste -p 2>/dev/null || xclip -selection primary   -o)\"; tmux paste-buffer"
#
#       =========================================================
#       New panes / windows (kitty: new window in cwd)
#       =========================================================
#       prefix + Enter  → new pane in CWD (≈ kitty_mod+enter)
#       bind-key Enter split-window -h -c "#{pane_current_path}"
#
#       Ctrl-q (no prefix) → claude in a side split via direnv (≈ your ctrl+q binding)
#       bind-key -n C-q split-window -h -c "#{pane_current_path}" "fish -lc 'direnv exec . claude'"
#
#       prefix + BSpace → cycle layouts (≈ kitty_mod+backspace next_layout)
#       bind-key BSpace next-layout
#
#       =========================================================
#       Pane navigation (kitty_mod+h / kitty_mod+l → next/prev window-in-tab → tmux pane)
#       =========================================================
#       bind-key h select-pane -t :.-
#       bind-key l select-pane -t :.+
#
#       kitty_mod+j / kitty_mod+k → scroll_to_prompt ±1
#       Adjust the regex below to your fish prompt glyph (default fish: '> '; starship/custom: '❯ ')
#       bind-key k copy-mode \; send-keys -X search-backward "❯ "
#       bind-key j if-shell -F '#{pane_in_mode}' \
#         'send-keys -X search-forward "❯ "' \
#         'copy-mode \; send-keys -X search-forward "❯ "'
#
#       =========================================================
#       Scrollback / last command output (kitty_mod+s>s, kitty_mod+s>ctrl+s)
#       =========================================================
#       bind-key s copy-mode
#       "last command output" requires OSC-133 prompt marks; fallback = jump to previous prompt:
#       bind-key C-s copy-mode \; send-keys -X search-backward "❯ "
    '';
  };
}
