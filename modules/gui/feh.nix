{ config
, lib
, pkgs
, ...
}:
{
  config = {
    programs.feh.enable = true;
    programs.feh.buttons = {
      prev_img = 1;
      pan = 2;
      next_img = 3;
      zoom_in = 4;
      zoom_out = 5;
    };
    programs.feh.keybindings = {
      menu_parent        = "Left";
      menu_child         = "Right";
      menu_down          = "Down";
      menu_up            = "Up";

      scroll_left        = "h";
      scroll_right       = "l";
      scroll_up          = "k";
      scroll_down        = "j";

      scroll_left_page   = "C-h";
      scroll_right_page  = "C-l";
      scroll_up_page     = "C-k";
      scroll_down_page   = "C-j";

      toggle_aliasing    = "A";
      toggle_filenames   = "d";
      toggle_pointer     = "o";
      toggle_fullscreen  = "f";

      zoom_in            = "plus";
      zoom_out           = "minus";

      next_img           = "greater";
      prev_img           = "less";
      reload_image       = "r";
      size_to_image      = "w";
      next_dir           = "bracketright";
      prev_dir           = "bracketleft";
      orient_3           = "parenright";
      orient_1           = "parenleft";
      flip               = "underscore";
      mirror             = "bar";
      remove             = "Delete";
      zoom_fit           = "s";
      zoom_default       = "a";

      close              = "q Q";
    };
  };
}