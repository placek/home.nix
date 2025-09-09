{ config
, lib
, pkgs
, ...
}:
{
  config = {
    services.dunst.enable = true;
    services.dunst.settings = {
      global = {
        follow = "none";
        monitor = 0;

        width = 500;
        origin = "top-right";
        offset = "8x8";
        padding = config.gui.border.size * 2;
        frame_width = config.gui.border.size;
        horizontal_padding = config.gui.border.size * 2;
        separator_color = config.gui.theme.base08;
        separator_height = config.gui.border.size;
        transparency = 0;

        font = "${config.gui.font.name} ${builtins.toString config.gui.font.size}";
        format = "<b>%a: %s</b>\n%b\n%p";
        ignore_newline = false;
        alignment = "left";
        markup = "full";
        line_height = 3;
        show_age_threshold = -1;
        indicate_hidden = true;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = false;

        mouse_left_click = "do_action";
        mouse_middle_click = "none";
        mouse_right_click = "close_current";

        word_wrap = true;
        browser = config.browserExec;

        startup_notification = false;
        history_length = 99;
        sticky_history = true;
        sort = false;
        idle_threshold = 0;
      };

      urgency_low = {
        frame_color = config.gui.theme.base03;
        background = config.gui.theme.base00;
        foreground = config.gui.theme.base07;
        msg_urgency = "low";
      };

      urgency_normal = {
        frame_color = config.gui.theme.base02;
        background = config.gui.theme.base00;
        foreground = config.gui.theme.base07;
        msg_urgency = "normal";
      };

      urgency_critical = {
        frame_color = config.gui.theme.base01;
        background = config.gui.theme.base00;
        foreground = config.gui.theme.base07;
        msg_urgency = "critical";
      };
    };
  };
}
