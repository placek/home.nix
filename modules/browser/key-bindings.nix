{ config
, lib
, pkgs
, ...
}:
{
  config.programs.qutebrowser.keyBindings.normal = {
    "I" = "hint inputs";

    "pS" = "open -t -- {clipboard}";
    "ps" = "cmd-set-text /{clipboard}";
    "yy" = "yank selection";
    "YY" = "yank";

    ";D" = "hint links spawn ${config.terminalExec} -e ${config.downloaderExec} {hint-url} -d ${config.downloadsDirectory}";
    ";m" = "hint links spawn ${config.terminalExec} -e ${config.ytDownloaderExec} -x {hint-url} -o ${config.downloadsDirectory}/%(title)s.%(ext)s";
    ";v" = "hint links spawn ${config.terminalExec} -e ${config.ytDownloaderExec} {hint-url} -o ${config.downloadsDirectory}/%(title)s.%(ext)s";
    ";g" = "hint links userscript GBrowse";

    ",re" = "spawn speak -len {primary}";
    ",rp" = "spawn speak -lpl {primary}";
    ",rs" = "spawn summarize -s {primary}";
    ",pp" = "spawn --userscript qute-pass --dmenu-invocation ${config.menuExec} --no-insert-mode --username-target secret --username-pattern \"user: (.+)\"";
    ",pP" = "spawn --userscript qute-pass --dmenu-invocation ${config.menuExec} --no-insert-mode --password-only";
    ",pl" = "spawn --userscript qute-pass --dmenu-invocation ${config.menuExec} --no-insert-mode --username-only --username-pattern \"user: (.+)\"";
    ",po" = "spawn --userscript qute-pass --dmenu-invocation ${config.menuExec} --no-insert-mode --otp-only";
    ",ps" = "spawn --userscript qute-pass --dmenu-invocation ${config.menuExec} --no-insert-mode --password-only --password-pattern \"secret: (.+)\"";
    ",g" = "spawn --userscript GBrowse";

    "gd" = "cmd-set-text -s :tab-take";
    "gl" = "tab-focus last";

    "<Space>l" = "tab-next";
    "<Space>h" = "tab-prev";

    "<Return>" = "mode-enter passthrough";
    "<Ctrl+h>" = "open -t https://start.duckduckgo.com/";

    "ta" = "config-cycle content.blocking.enabled";
    "tr" = "config-cycle colors.webpage.darkmode.enabled";
  };
}
