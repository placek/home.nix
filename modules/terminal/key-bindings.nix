let
  hintsSettings = "--alphabet 'asdfghjkl' --hints-foreground-color black --hints-background-color yellow --hints-text-color blue";
in
{
  "super+c" = "copy_to_clipboard";
  "super+v" = "paste_from_clipboard";
  "super+x" = "paste_from_selection";

  "kitty_mod+right" = "next_window";
  "kitty_mod+left" = "previous_window";
  "kitty_mod+up" = "next_tab";
  "kitty_mod+down" = "previous_tab";

  "kitty_mod+shift+right" = "move_tab_forward";
  "kitty_mod+shift+left" = "move_tab_backward";
  "kitty_mod+shift+up" = "move_window_backward";
  "kitty_mod+shift+down" = "move_window_forward";

  "kitty_mod+enter" = "launch --type=window --cwd=current --title current";
  "kitty_mod+esc" = "launch --type=tab --cwd=current --title current";

  "kitty_mod+space" = "next_layout";

  "kitty_mod+l" = "scroll_line_up";
  "kitty_mod+m" = "scroll_line_down";

  "kitty_mod+shift+l" = "scroll_to_prompt -1";
  "kitty_mod+shift+m" = "scroll_to_prompt +1";

  "kitty_mod+." = "show_scrollback";
  "kitty_mod+," = "show_last_command_output";

  "kitty_mod+q>p" = "kitten hints ${hintsSettings} --window-title 'choose path' --type path --program -";
  "kitty_mod+q>h" = "kitten hints ${hintsSettings} --window-title 'choose hash' --regex '([0-9a-fA-F-]+)' --type regex --program -";
  "kitty_mod+q>e" = "kitten unicode_input";
  "kitty_mod+q>u" = "kitten hints ${hintsSettings} --window-title 'choose hyperlink' --type hyperlink";
}
