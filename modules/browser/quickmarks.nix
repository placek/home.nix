{ config
, ...
}:
{
  config.xdg.configFile."qutebrowser/bookmarks/urls".source = ./bookmarks;
  config.programs.qutebrowser.quickmarks = {
    "Gmail" = "https://mail.google.com/";
    "Drive" = "https://drive.google.com/";
    "Calendar" = "https://calendar.google.com/";
    "Meet" = "https://meet.google.com/";
    "Keep" = "https://keep.google.com/u/0/";
    "BA::Slack" = "https://app.slack.com/client/T02GP5QUP/unreads";
    "BA::Jira" = "https://jira.binarapps.com/secure/Dashboard.jspa";
    "BA::Confluence" = "https://confluence.binarapps.com/";
    "BA::GitLab" = "https://gitlab.binarapps.com/dashboard/groups";
    "BA::Traffit" = "https://binarapps.traffit.com/";
    "SMS" = "https://messages.google.com/web/conversations";
    "WhatsApp" = "https://web.whatsapp.com/";
    "Messenger" = "https://www.messenger.com/";
    "mBank" = "https://online.mbank.pl/pl/Login";
    "Allegro" = "https://allegro.pl/";
    "GitHub" = "https://github.com/";
    "LiChess" = "https://lichess.org/";
    "Pinterest" = "https://pl.pinterest.com/?autologin=true";
    "Pocket" = "https://getpocket.com/my-list";
    "Reddit" = "https://www.reddit.com/";
    "YouTube" = "https://www.youtube.com/";
  };
}
