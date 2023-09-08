let
  hintsSettings = "--alphabet 'asdfghjkl' --hints-foreground-color black --hints-background-color yellow --hints-text-color blue";
in
{
  "super+c" = "copy_to_clipboard";
  "super+v" = "paste_from_clipboard";
  "super+x" = "paste_from_selection";

  "kitty_mod+k" = "scroll_line_up";
  "kitty_mod+j" = "scroll_line_down";

  "kitty_mod+h" = "change_font_size all -2.0";
  "kitty_mod+l" = "change_font_size all +2.0";

  "kitty_mod+alt+k" = "scroll_to_prompt -1";
  "kitty_mod+alt+j" = "scroll_to_prompt +1";

  "kitty_mod+." = "show_scrollback";
  "kitty_mod+," = "show_last_command_output";

  "kitty_mod+z" = "next_layout";

  "kitty_mod+enter" = "launch --type=window --cwd=current --title current";
  "kitty_mod+space" = "launch --type=tab --cwd=current --title current";

  "kitty_mod+right" = "next_window";
  "kitty_mod+left" = "previous_window";
  "kitty_mod+up" = "next_tab";
  "kitty_mod+down" = "previous_tab";

  "kitty_mod+t" = "set_tab_title";
  "kitty_mod+a" = "kitten hints ${hintsSettings} --window-title 'choose path' --type path --program -";
  "kitty_mod+s" = "kitten hints ${hintsSettings} --window-title 'choose hash' --type hash --program -";
  "kitty_mod+d" = "kitten hints ${hintsSettings} --window-title 'choose hash' --regex '([0-9a-fA-F-]+)' --type regex --program -";
  "kitty_mod+f" = "kitten hints ${hintsSettings} --window-title 'choose hyperlink' --type hyperlink";
  "kitty_mod+g" = "kitten unicode_input";

  "kitty_mod+alt+left" = "resize_window narrower";
  "kitty_mod+alt+right" = "resize_window wider";
  "kitty_mod+alt+up" = "resize_window taller";
  "kitty_mod+alt+down" = "resize_window shorter";
}
