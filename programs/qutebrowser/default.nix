let
  settings = import ../../settings;
  term = "kitty";
  editor = "vim";
  fileManager = "nnn";
  downloader = "aria2c";
  ytdownloader = "youtube-dl";
in
{
  enable = true;
  loadAutoconfig = false;
  searchEngines = {
    DEFAULT = "https://www.google.com/search?q={}";
    allegro = "https://allegro.pl/listing?string={}";
    alpha = "http://www.wolframalpha.com/input/?i={}";
    ang = "https://context.reverso.net/t%C5%82umaczenie/polski-angielski/{}";
    duck = "https://duckduckgo.com/?q={}";
    stack = "https://stackexchange.com/search?q={}";
    d = "https://hub.docker.com/search?q={}&type=image";
    h = "https://hoogle.haskell.org/?hoogle={}";
    m = "http://maps.google.com/maps?q={}";
    nm = "https://nixos.org/manual/nix/stable/introduction.html?search={}";
    np = "https://search.nixos.org/packages?query={}";
    npv = "https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package={}";
    p = "https://getpocket.com/my-list/search?query={}";
    rb = "https://ruby-doc.com/search.html?q={}";
    we = "https://en.wikipedia.org/wiki/{}";
    wp = "https://pl.wikipedia.org/wiki/{}";
    yt = "https://www.youtube.com/results?search_query={}";
  };
  keyBindings.normal = {
    ";D" = "hint links spawn ${term} -e ${downloader} {hint-url} -d ${settings.dirs.downloads}";
    ";m" = "hint links spawn ${term} -e ${ytdownloader} -x {hint-url} -o ${settings.dirs.downloads}/%(title)s.%(ext)s";
    ";v" = "hint links spawn ${term} -e ${ytdownloader} {hint-url} -o ${settings.dirs.downloads}/%(title)s.%(ext)s";
    "<Ctrl+w>" = "mode-enter passthrough";
    "I" = "hint inputs";
    ",s" = "open -t https://getpocket.com/edit?url={url}";
  };
  quickmarks = {
    "Gmail" = "https://mail.google.com/";
    "Calendar" = "https://calendar.google.com/";
    "Meet" = "https://meet.google.com/";
    "Keep" = "https://keep.google.com/u/0/";
    "BA::Slack" = "https://app.slack.com/client/T02GP5QUP/unreads";
    "BA::Jira" = "https://jira.binarapps.com/secure/Dashboard.jspa";
    "BA::Confluence" = "https://confluence.binarapps.com/";
    "BA::GitLab" = "https://gitlab.binarapps.com/dashboard/groups";
    "BA::Traffit" = "https://binarapps.traffit.com/";
    "Byron::Jira" = "https://byron-network.atlassian.net/jira/software/c/projects/BN/boards/4";
    "SMS" = "https://messages.google.com/web/conversations";
    "WhatsApp" = "https://web.whatsapp.com/";
    "Messenger" = "https://www.messenger.com/";
    "Allegro" = "https://allegro.pl/";
    "GitHub" = "https://github.com/";
    "LiChess" = "https://lichess.org/";
    "Pinterest" = "https://pl.pinterest.com/?autologin=true";
    "Pocket" = "https://getpocket.com/my-list";
    "Reddit" = "https://www.reddit.com/";
    "YouTube" = "https://www.youtube.com/";
  };
  extraConfig = ''
    config.unbind('<Ctrl+Shift+w>')
    config.unbind('<Ctrl+t>')
    config.unbind('<Ctrl+n>')
    config.unbind('<Ctrl+Shift+n>')
  '';
  aliases = {
    "q" = "quit";
    "w" = "session-save";
    "wq" = "quit --save";
  };
  settings = {
    confirm_quit = [ "multiple-tabs" "downloads" ];
    content = {
      default_encoding = "utf-8";
      tls.certificate_errors = "load-insecurely";
      notifications.enabled = true;
      media = {
        audio_capture = true;
        audio_video_capture = true;
        video_capture = true;
      };
    };
    downloads.location.directory = settings.dirs.downloads;
    editor.command = [ term "-e" editor "-f" "{file}" "-c" "normal" "{line}G{column0}l" ];
    fileselect = {
      handler = "external";
      multiple_files.command = [ term "-e" fileManager "-p" "{}" ];
      single_file.command = [ term "-e" fileManager "-p" "{}" ];
    };
    hints.border = "none";
    hints.radius = 4;
    # FIXME: statusbar.padding = { bottom = 4; left = 4; right = 4; top = 4; };
    tabs = {
      favicons.show = "never";
      indicator.width = 0;
      last_close = "close";
      mousewheel_switching = false;
      # FIXME: padding = { bottom = 4; left = 8; right = 8; top = 4; };
      show = "always";
      title.format = "{index}{audio} | {current_title}";
      tooltips = false;
    };
    window.title_format = "{current_title}";

    fonts = {
      default_family = settings.font.fullName;
      default_size = settings.font.size.pt;
      completion.entry = "${settings.font.size.pt} ${settings.font.fullName}";
      contextmenu = "${settings.font.size.pt} ${settings.font.fullName}";
      debug_console = "${settings.font.size.pt} ${settings.font.fullName}";
      prompts = "${settings.font.size.pt} ${settings.font.fullName}";
      statusbar = "${settings.font.size.pt} ${settings.font.fullName}";
    };

    colors = with settings.colors; {
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
    };
  };
}
