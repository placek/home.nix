{ config
, lib
, pkgs
, ...
}:
let
  qutebrowser = config.programs.qutebrowser.package;
  hyprBrowser = pkgs.writeShellScriptBin "hypr-browser" ''
    hyprctl dispatch exec "[workspace 1 silent] ${qutebrowser}/bin/qutebrowser" "$@"
  '';
in
{
  options = with lib; {
    browserExec = mkOption {
      type = types.str;
      default = "${hyprBrowser}/bin/hypr-browser";
      description = "Browser executable.";
      readOnly = true;
    };
  };

  imports = [
    ./aliases.nix
    ./key-bindings.nix
    ./quickmarks.nix
    ./settings.nix
    ./search-engines.nix

    ./scripts
  ];

  config = {
    home.sessionVariables.QT_QPA_PLATFORM = "xcb";
    home.sessionVariables.QTWEBENGINE_CHROMIUM_FLAGS = "--disable-gpu-sandbox";

    # backup browser
    programs.firefox.enable = true;

    xdg.desktopEntries.qutebrowser = {
      name = "QuteBrowser";
      genericName = "qutebrowser";
      type = "Application";
      exec = "${hyprBrowser}/bin/hypr-browser %u";
      terminal = false;
      icon = "browser";
    };

    xdg.enable = true;
    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "qutebrowser.desktop" ];
      "x-scheme-handler/http" = [ "qutebrowser.desktop" ];
      "x-scheme-handler/https" = [ "qutebrowser.desktop" ];
    };

    xdg.configFile."qutebrowser/userscripts/GBrowse" = {
      source = ./GBrowse;
      executable = true;
    };

    programs.qutebrowser = {
      enable = true;
      searchEngines = config.browser.searchEngines;
    };
  };
}
