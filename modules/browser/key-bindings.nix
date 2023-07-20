{ downloadsDirectory
, terminalExec
, downloaderExec
, ytDownloaderExec
, menuExec
, ...
}:
{
  normal = {
    ";D" = "hint links spawn ${terminalExec} -e ${downloaderExec} {hint-url} -d ${downloadsDirectory}";
    ";m" = "hint links spawn ${terminalExec} -e ${ytDownloaderExec} -x {hint-url} -o ${downloadsDirectory}/%(title)s.%(ext)s";
    ";v" = "hint links spawn ${terminalExec} -e ${ytDownloaderExec} {hint-url} -o ${downloadsDirectory}/%(title)s.%(ext)s";
    ";g" = "hint links userscript GBrowse";
    "<Ctrl+w>" = "mode-enter passthrough";
    "I" = "hint inputs";
    ",s" = "open -t https://getpocket.com/edit?url={url}";
    ",re" = "spawn speak -len {primary}";
    ",rp" = "spawn speak -lpl {primary}";
    ",pp" = "spawn --userscript qute-pass --dmenu-invocation ${menuExec} --no-insert-mode --username-target secret --username-pattern \"user: (.+)\"";
    ",pP" = "spawn --userscript qute-pass --dmenu-invocation ${menuExec} --no-insert-mode --password-only";
    ",pL" = "spawn --userscript qute-pass --dmenu-invocation ${menuExec} --no-insert-mode --username-only --username-pattern \"user: (.+)\"";
    ",pO" = "spawn --userscript qute-pass --dmenu-invocation ${menuExec} --no-insert-mode --otp-only";
    ",pS" = "spawn --userscript qute-pass --dmenu-invocation ${menuExec} --no-insert-mode --password-only --password-pattern \"secret: (.+)\"";
    "<Super-c>" = "yank selection";
    "<Super-v>" = "insert-text -- {clipboard}";
    "<Ctrl+h>" = "open -t https://start.duckduckgo.com/";
  };
  insert = {
    "<Super-c>" = "yank selection";
    "<Super-v>" = "insert-text -- {clipboard}";
  };
}
