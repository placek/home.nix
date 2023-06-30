{ shellExec
, editorExec
, theme
, ...
}:
with theme; {
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
  shell = shellExec;
  editor = editorExec;
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
  active_border_color = base03;
  inactive_border_color = base08;
  bell_border_color = base03;
  background = base00;
  foreground = base0F;
  selection_background = base04;
  selection_foreground = base0F;
  background_opacity = "0.9";
  url_color = base04;
  cursor = base0F;
  color0 = base00;
  color1 = base01;
  color2 = base02;
  color3 = base03;
  color4 = base04;
  color5 = base05;
  color6 = base06;
  color7 = base07;
  color8 = base08;
  color9 = base09;
  color10 = base0A;
  color11 = base0B;
  color12 = base0C;
  color13 = base0D;
  color14 = base0E;
  color15 = base0F;
}
