{ config
, ...
}:
{
  config.xdg.configFile."qutebrowser/greasemonkey/youtube-adb.js".source = ./youtube-adb.js;
}
