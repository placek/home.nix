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
  config.programs.kitty.extraConfig = ''
    mouse_map left  press       ungrabbed mouse_selection normal
    mouse_map left  click       ungrabbed mouse_handle_click selection link prompt
    mouse_map left  doublepress ungrabbed mouse_selection word
    mouse_map left  triplepress ungrabbed mouse_selection line
    mouse_map right press       ungrabbed mouse_selection extend
  '';
  config.programs.kitty.keybindings = {
    "kitty_mod+shift+c" = "copy_to_clipboard";
    "kitty_mod+shift+v" = "paste_from_clipboard";
    "kitty_mod+shift+x" = "paste_from_selection";

    "super+c" = "copy_to_clipboard";
    "super+v" = "paste_from_clipboard";
    "super+x" = "paste_from_selection";

    "kitty_mod+enter" = "launch --type=window --cwd=current";
    "kitty_mod+backspace" = "next_layout";

    "kitty_mod+h" = "next_window";
    "kitty_mod+l" = "previous_window";
    "kitty_mod+k" = "scroll_to_prompt -1";
    "kitty_mod+j" = "scroll_to_prompt +1";

    "kitty_mod+s>s" = "show_scrollback";
    "kitty_mod+s>ctrl+s" = "show_last_command_output";

    "kitty_mod+s>p" = "kitten hints ${hints} --window-title 'choose path' --type path --program -";
    "kitty_mod+s>ctrl+p" = "kitten hints ${hints} --window-title 'choose path' --type path --program @";

    "kitty_mod+s>h" = "kitten hints ${hints} --window-title 'choose hash' --regex '([0-9a-fA-F-]+)' --type regex --program -";
    "kitty_mod+s>ctrl+h" = "kitten hints ${hints} --window-title 'choose hash' --regex '([0-9a-fA-F-]+)' --type regex --program @";

    "kitty_mod+s>u" = "kitten hints ${hints} --window-title 'choose hyperlink' --type hyperlink";
    "kitty_mod+s>ctrl+u" = "kitten hints ${hints} --window-title 'choose hyperlink' --type hyperlink --program @";

    "kitty_mod+s>e" = "kitten unicode_input";
  };
}
