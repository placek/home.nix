{ config
, ...
}:
{
  config.xdg.configFile."qutebrowser/bookmarks/urls".source = ./bookmarks;
  config.programs.qutebrowser.quickmarks = {
    "Gmail" = "https://mail.google.com/";
    "Drive" = "https://drive.google.com/";
    "Meet" = "https://meet.google.com/";
    "Keep" = "https://keep.google.com/u/0/";
    "BA::Jira" = "https://jira.binarapps.com/secure/Dashboard.jspa";
    "BA::GitLab" = "https://gitlab.binarapps.com/dashboard/groups";
    "WhatsApp" = "https://web.whatsapp.com/";
    "Messenger" = "https://www.messenger.com/";
    "mBank" = "https://online.mbank.pl/pl/Login";
    "Allegro" = "https://allegro.pl/";
    "GitHub" = "https://github.com/";
    "Raindrop" = "https://app.raindrop.io/";
    "YouTube" = "https://www.youtube.com/";
  };
}
