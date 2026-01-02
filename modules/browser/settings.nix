{ config
, lib
, pkgs
, ...
}:
let
  inherit (config) terminalExec editorExec fileManagerExec downloadsDirectory;
  inherit (config.gui) theme font;
  fontSizePt = "${builtins.toString font.size}pt";
  fontSetting = "${builtins.toString font.size}pt ${font.name}";
in
{
  config.programs.qutebrowser.loadAutoconfig = false;
  config.programs.qutebrowser.extraConfig = builtins.readFile ./extraConfig;
  config.programs.qutebrowser.settings = {
    qt.args = [
      "disable-features=PermissionElement"
    ];
    confirm_quit = [ "multiple-tabs" "downloads" ];

    content.desktop_capture = true;
    content.geolocation = true;
    content.mouse_lock = true;
    content.media.audio_video_capture = true;
    content.notifications.enabled = true;
    content.persistent_storage = true;
    content.register_protocol_handler = true;
    content.javascript.clipboard = "access-paste";

    downloads.location.directory = downloadsDirectory;

    editor.command = [ terminalExec "-e" editorExec "-f" "{file}" "-c" "normal" "{line}G{column0}l" ];

    fileselect.handler = "external";
    fileselect.multiple_files.command = [ terminalExec "-e" fileManagerExec "-p" "{}" ];
    fileselect.single_file.command = [ terminalExec "-e" fileManagerExec "-p" "{}" ];

    hints.border = "none";
    hints.radius = 4;
    hints.auto_follow = "always";

    tabs.favicons.show = "never";
    tabs.indicator.width = 0;
    tabs.last_close = "close";
    tabs.mousewheel_switching = false;
    tabs.show = "always";
    tabs.title.format = "{index}{audio} | {current_title}";
    tabs.tooltips = false;

    window.title_format = "{current_title}";

    fonts.default_family = font.name;
    fonts.default_size = fontSizePt;
    fonts.completion.entry = fontSetting;
    fonts.contextmenu = fontSetting;
    fonts.debug_console = fontSetting;
    fonts.prompts = fontSetting;
    fonts.statusbar = fontSetting;

    zoom.mouse_divider = 0;

    colors = with theme; {
      completion.fg = base0F;
      completion.odd.bg = base08;
      completion.even.bg = base00;
      completion.category.fg = base07;
      completion.category.bg = base00;
      completion.category.border.top = base00;
      completion.category.border.bottom = base00;
      completion.item.selected.fg = base00;
      completion.item.selected.bg = base0B;
      completion.item.selected.border.top = base03;
      completion.item.selected.border.bottom = base03;
      completion.item.selected.match.fg = base00;
      completion.match.fg = base03;
      completion.scrollbar.fg = base0F;
      completion.scrollbar.bg = base00;

      contextmenu.disabled.bg = base00;
      contextmenu.disabled.fg = base08;
      contextmenu.menu.bg = base00;
      contextmenu.menu.fg = base0F;
      contextmenu.selected.bg = base0B;
      contextmenu.selected.fg = base00;

      downloads.bar.bg = base00;
      downloads.start.fg = base00;
      downloads.start.bg = base04;
      downloads.stop.fg = base00;
      downloads.stop.bg = base02;
      downloads.error.fg = base01;

      hints.fg = base00;
      hints.bg = base0B;
      hints.match.fg = base05;

      keyhint.fg = base07;
      keyhint.suffix.fg = base0F;
      keyhint.bg = base00;

      messages.error.fg = base00;
      messages.error.bg = base01;
      messages.error.border = base00;
      messages.warning.fg = base00;
      messages.warning.bg = base03;
      messages.warning.border = base00;
      messages.info.fg = base00;
      messages.info.bg = base04;
      messages.info.border = base00;

      prompts.fg = base0F;
      prompts.border = base00;
      prompts.bg = base00;
      prompts.selected.fg = base00;
      prompts.selected.bg = base0B;

      statusbar.normal.fg = base0B;
      statusbar.normal.bg = base00;
      statusbar.insert.fg = base00;
      statusbar.insert.bg = base0D;
      statusbar.passthrough.fg = base00;
      statusbar.passthrough.bg = base0D;
      statusbar.private.fg = base00;
      statusbar.private.bg = base08;
      statusbar.command.fg = base0F;
      statusbar.command.bg = base00;
      statusbar.command.private.fg = base0F;
      statusbar.command.private.bg = base00;
      statusbar.caret.fg = base00;
      statusbar.caret.bg = base0D;
      statusbar.caret.selection.fg = base00;
      statusbar.caret.selection.bg = base0D;
      statusbar.progress.bg = base02;
      statusbar.url.fg = base0F;
      statusbar.url.error.fg = base01;
      statusbar.url.hover.fg = base0F;
      statusbar.url.success.http.fg = base0C;
      statusbar.url.success.https.fg = base0B;
      statusbar.url.warn.fg = base0E;

      tabs.bar.bg = base00;
      tabs.indicator.start = base0D;
      tabs.indicator.stop = base0C;
      tabs.indicator.error = base08;
      tabs.odd.fg = base0F;
      tabs.odd.bg = base08;
      tabs.even.fg = base0F;
      tabs.even.bg = base00;
      tabs.pinned.odd.fg = base0F;
      tabs.pinned.odd.bg = base08;
      tabs.pinned.even.fg = base0F;
      tabs.pinned.even.bg = base00;
      tabs.pinned.selected.odd.fg = base0B;
      tabs.pinned.selected.odd.bg = base08;
      tabs.pinned.selected.even.fg = base0B;
      tabs.pinned.selected.even.bg = base00;
      tabs.selected.odd.fg = base0B;
      tabs.selected.odd.bg = base08;
      tabs.selected.even.fg = base0B;
      tabs.selected.even.bg = base00;

      webpage.darkmode.enabled = false;
      webpage.darkmode.policy.images = "smart";
      webpage.darkmode.algorithm = "lightness-cielab";
      webpage.darkmode.contrast = 0.3;
    };
  };
}
