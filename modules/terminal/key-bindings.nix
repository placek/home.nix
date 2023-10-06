let
  hintsSettings = "--alphabet 'asdfghjkl' --hints-foreground-color black --hints-background-color yellow --hints-text-color blue";
in
{
  "kitty_mod+ctrl+c" = "copy_to_clipboard";
  "kitty_mod+ctrl+v" = "paste_from_clipboard";
  "kitty_mod+ctrl+x" = "paste_from_selection";

  "kitty_mod+l" = "next_window";
  "kitty_mod+h" = "previous_window";
  "kitty_mod+shift+h" = "move_window_backward";
  "kitty_mod+shift+l" = "move_window_forward";

  "kitty_mod+esc" = "launch --type=window --cwd=current --title current";

  "kitty_mod+space" = "next_layout";

  "kitty_mod+k" = "scroll_line_up";
  "kitty_mod+j" = "scroll_line_down";

  "kitty_mod+shift+k" = "scroll_to_prompt -1";
  "kitty_mod+shift+j" = "scroll_to_prompt +1";

  "kitty_mod+b" = "show_scrollback";
  "kitty_mod+shift+b" = "show_last_command_output";

  "kitty_mod+q>p" = "kitten hints ${hintsSettings} --window-title 'choose path' --type path --program -";
  "kitty_mod+q>h" = "kitten hints ${hintsSettings} --window-title 'choose hash' --regex '([0-9a-fA-F-]+)' --type regex --program -";
  "kitty_mod+q>e" = "kitten unicode_input";
  "kitty_mod+q>u" = "kitten hints ${hintsSettings} --window-title 'choose hyperlink' --type hyperlink";
}
