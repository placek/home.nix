{ config
, ...
}:
{
  config = {
    services.flameshot.enable = true;
    services.flameshot.settings.General = {
      disabledTrayIcon = true;
      showStartupLaunchMessage = false;
      savePath = config.downloadsDirectory;
      savePathFixed = true;
      saveAsFileExtension = ".png";
      uiColor = config.gui.theme.base00;
      contrastUiColor = config.gui.theme.base05;
      showHelp = true;
    };
  };
}
