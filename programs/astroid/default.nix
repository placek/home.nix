{
  enable = true;
  externalEditor = ''
    kitty vim "+set ft=mail" "+set fileencoding=utf-8" "+set ff=unix" "+set enc=utf-8" "+set fo+=w" %1
  '';
  extraConfig = {
    startup.queries = {
      placzynski = "folder:placzynski/Inbox";
      silquenarmo = "folder:silquenarmo/Inbox";
      binarapps = "folder:binarapps/Inbox";
      byron = "folder:byron/Inbox";
      futurelearn = "folder:futurelearn/Inbox";
    };
  };
}
