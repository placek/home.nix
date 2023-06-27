{ config, pkgs, ... }:
let
  sources = import ../home.lock.nix;
  settings = import ../settings;
  shell = "fish";
  editor = "vim";
  hintsSettings = "--alphabet 'asdfghjkl' --hints-foreground-color black --hints-background-color yellow --hints-text-color blue";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "kitty-gl" ''
      #!/usr/bin/env bash
      ${sources.glpkgs.nixGLIntel}/bin/nixGLIntel kitty "$@"
    '')
  ];

  xdg.desktopEntries.kitty = {
    name = "Terminal";
    genericName = "Terminal";
    type = "Application";
    exec = "kitty-gl";
    terminal = false;
    icon = "${pkgs.papirus-icon-theme}/share/icons/ePapirus-Dark/128x128/apps/terminal.svg";
  };

  programs.fish.shellAliases.icat = "kitty +kitten icat";

  programs.kitty = {
    enable = true;
    font = {
      name = settings.font.fullName;
      size = settings.font.size.int;
    };
    keybindings = {
      "super+c" = "copy_to_clipboard";
      "super+v" = "paste_from_clipboard";
      "super+x" = "paste_from_selection";
      "shift+insert" = "paste_from_clipboard"; # because clipboard manager on gnome shell uses this shortcut to paste from clipboard

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
    };
    settings = {
      force_ltr = "no";
      disable_ligatures = "always";
      font_features = "none";
      box_drawing_scale = "0.001, 1, 1.5, 2";

      # Cursor customization
      cursor_shape = "block";
      cursor_blink_interval = "1";
      cursor_stop_blinking_after = "15.0";

      # Scrollback
      scrollback_lines = "2000";
      scrollback_pager = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";
      scrollback_pager_history_size = "9999";
      wheel_scroll_multiplier = "5.0";
      touch_scroll_multiplier = "1.0";

      # Mouse
      mouse_hide_wait = "0";
      url_style = "curly";
      open_url_with = "default";
      url_prefixes = "file ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh";
      detect_urls = "yes";
      copy_on_select = "no";
      select_by_word_characters = "@-./_~?&=%+#";
      click_interval = "-1.0";
      focus_follows_mouse = "no";

      # Performance tuning
      repaint_delay = "10";
      input_delay = "3";
      sync_to_monitor = "yes";

      # Terminal bell
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      window_alert_on_bell = "no";
      bell_on_tab = "no";
      command_on_bell = "none";

      # Window layout
      remember_window_size = "no";
      enabled_layouts = "tall:bias=62;full_size=1,stack";
      window_resize_step_cells = "2";
      window_resize_step_lines = "2";
      window_border_width = "4px";
      draw_minimal_borders = "yes";
      window_margin_width = "0";
      window_padding_width = "4";
      placement_strategy = "center";
      inactive_text_alpha = "0.9";
      hide_window_decorations = "yes";
      resize_debounce_time = "0.1";
      resize_draw_strategy = "static";
      resize_in_steps = "no";
      confirm_os_window_close = "0";
      single_window_margin_width = "-1";

      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_background = "none";
      tab_bar_margin_width = "0.0";
      tab_bar_min_tabs = "2";
      tab_bar_style = "powerline";
      tab_switch_strategy = "previous";
      tab_title_template = "{fmt.fg.yellow}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}";
      shell = shell;
      editor = editor;
      close_on_child_death = "yes";
      allow_remote_control = "no";
      update_check_interval = "0";
      startup_session = "none";
      clipboard_control = "write-clipboard write-primary";
      allow_hyperlinks = "yes";
      shell_integration = "no-cursor";
      strip_trailing_spaces = "never";
      term = "xterm-kitty";
      kitty_mod = "ctrl+shift";
      clear_all_shortcuts = "yes";
      clear_all_mouse_actions = "yes";

      # Color scheme
      active_border_color = settings.colors.base03;
      inactive_border_color = settings.colors.base08;
      bell_border_color = settings.colors.base03;
      background = settings.colors.base00;
      foreground = settings.colors.base0F;
      selection_background = settings.colors.base04;
      selection_foreground = settings.colors.base0F;
      background_opacity = "0.9";
      url_color = settings.colors.base04;
      cursor = settings.colors.base0F;
      color0 = settings.colors.base00;
      color1 = settings.colors.base01;
      color2 = settings.colors.base02;
      color3 = settings.colors.base03;
      color4 = settings.colors.base04;
      color5 = settings.colors.base05;
      color6 = settings.colors.base06;
      color7 = settings.colors.base07;
      color8 = settings.colors.base08;
      color9 = settings.colors.base09;
      color10 = settings.colors.base0A;
      color11 = settings.colors.base0B;
      color12 = settings.colors.base0C;
      color13 = settings.colors.base0D;
      color14 = settings.colors.base0E;
      color15 = settings.colors.base0F;
    };
    extraConfig = ''
      mouse_map left       press       ungrabbed mouse_selection normal
      mouse_map left       click       ungrabbed mouse_handle_click selection link prompt
      mouse_map left       doublepress ungrabbed mouse_selection word
      mouse_map left       triplepress ungrabbed mouse_selection line
      mouse_map ctrl+left  press       ungrabbed mouse_selection rectangle
      mouse_map right      press       ungrabbed mouse_selection extend
      mouse_map ctrl+right press       ungrabbed mouse_select_command_output
    '';
  };
}
