{ config
, ...
}:
{
  config.programs.qutebrowser.aliases = {
    "s" = "session-load default";
    "q" = "quit";
    "w" = "session-save";
    "wq" = "quit --save";
    "GBrowse" = "spawn --userscript GBrowse";
  };
}
