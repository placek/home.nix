{ config
, lib
, pkgs
, ...
}:
let
  hintsSettings = {
    alphabet = "asdfghjkl";
    hints-foreground-color = "black";
    hints-background-color = "yellow";
    hints-text-color = "blue";
  };
  hints = lib.strings.concatStringsSep " " (builtins.attrValues (builtins.mapAttrs (a: b: "--${a} '${b}'") hintsSettings));
in
{
  config.programs.kitty.keybindings = {
    "kitty_mod+shift+c" = "copy_to_clipboard";
    "kitty_mod+shift+v" = "paste_from_clipboard";
    "kitty_mod+shift+x" = "paste_from_selection";

    "kitty_mod+enter" = "launch --type=window --cwd=current";
    "kitty_mod+shift+enter" = "next_layout";

    "kitty_mod+h" = "next_window";
    "kitty_mod+l" = "previous_window";
    "kitty_mod+k" = "scroll_to_prompt -1";
    "kitty_mod+j" = "scroll_to_prompt +1";

    "kitty_mod+b" = "show_scrollback";
    "kitty_mod+shift+b" = "show_last_command_output";

    "kitty_mod+q>p" = "kitten hints ${hints} --window-title 'choose path' --type path --program -";
    "kitty_mod+q>ctrl+p" = "kitten hints ${hints} --window-title 'choose path' --type path --program @";
    "kitty_mod+q>h" = "kitten hints ${hints} --window-title 'choose hash' --regex '([0-9a-fA-F-]+)' --type regex --program -";
    "kitty_mod+q>ctrl+h" = "kitten hints ${hints} --window-title 'choose hash' --regex '([0-9a-fA-F-]+)' --type regex --program @";
    "kitty_mod+q>u" = "kitten hints ${hints} --window-title 'choose hyperlink' --type hyperlink";
    "kitty_mod+q>ctrl+u" = "kitten hints ${hints} --window-title 'choose hyperlink' --type hyperlink --program @";
    "kitty_mod+q>e" = "kitten unicode_input";
  };
}
