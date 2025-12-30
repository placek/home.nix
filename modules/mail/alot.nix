{ config
, pkgs
, ...
}:
let
  defaultSearch = "search tag:unread and not tag:spam and not tag:killed";
in
{
  config = {
    programs.alot.enable = true;

    programs.alot.settings.initial_command = defaultSearch;
    programs.alot.settings.handle_mouse = true;
    programs.alot.settings.prefer_plaintext = true;
    programs.alot.settings.attachment_prefix = "${config.home.homeDirectory}/Downloads/";
    programs.alot.settings.thread_statusbar = "[{buffer_no}: thread] {subject}, {input_queue} messages: {message_count}";
    programs.alot.settings.quit_on_last_bclose = true;

    programs.alot.bindings.global = {
      "q" = "bclose; refresh;";
      "d" = "";
      "\\" = "";
      "|" = "";
      "U" = "";
      "esc" = "bufferlist";
      "I" = defaultSearch;
      "t" = "taglist";
    };

    programs.alot.bindings.search = {
      "&" = "";
      "l" = "";
      "O" = "";
      "/" = "refineprompt";
      "enter" = "select; fold *; untag unread;";
    };

    home.file.mailcap = {
      enable = true;
      target = ".mailcap";
      text = ''
        text/html; ${pkgs.w3m}/bin/w3m -dump -o document_charset=%{charset} -o display_link_number=1 '%s'; nametemplate=%s.html; copiousoutput
      '';
    };
  };
}
