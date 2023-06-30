{ terminal
, downloader
, ytDownloader
, downloadsDirectory
, menu
, ...
}:
{
  normal = {
    ";D" = "hint links spawn ${terminal} -e ${downloader} {hint-url} -d ${downloadsDirectory}";
    ";m" = "hint links spawn ${terminal} -e ${ytDownloader} -x {hint-url} -o ${downloadsDirectory}/%(title)s.%(ext)s";
    ";v" = "hint links spawn ${terminal} -e ${ytDownloader} {hint-url} -o ${downloadsDirectory}/%(title)s.%(ext)s";
    "<Ctrl+w>" = "mode-enter passthrough";
    "I" = "hint inputs";
    ",s" = "open -t https://getpocket.com/edit?url={url}";
    ",pp" = "spawn --userscript qute-pass --dmenu-invocation ${menu} --no-insert-mode --username-target secret --username-pattern \"user: (.+)\"";
    ",pP" = "spawn --userscript qute-pass --dmenu-invocation ${menu} --no-insert-mode --password-only";
    ",pL" = "spawn --userscript qute-pass --dmenu-invocation ${menu} --no-insert-mode --username-only --username-pattern \"user: (.+)\"";
    ",pO" = "spawn --userscript qute-pass --dmenu-invocation ${menu} --no-insert-mode --otp-only";
    ",pS" = "spawn --userscript qute-pass --dmenu-invocation ${menu} --no-insert-mode --password-only --password-pattern \"secret: (.+)\"";
    "<Super-c>" = "yank selection";
    "<Super-v>" = "insert-text -- {clipboard}";
    "<Ctrl+h>" = "open -t https://start.duckduckgo.com/";
  };
  insert = {
    "<Super-c>" = "yank selection";
    "<Super-v>" = "insert-text -- {clipboard}";
  };
}
