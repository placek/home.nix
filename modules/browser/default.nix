{ config
, lib
, pkgs
, ...
}:
let
  qutebrowser = pkgs.qutebrowser;
  hyprBrowser = pkgs.writeShellScriptBin "hypr-browser" ''
    hyprctl dispatch exec "[workspace 1 silent] ${qutebrowser}/bin/qutebrowser" "$@"
  '';
in
{
  options = with lib; {
    browserExec = mkOption {
      type = types.str;
      default = "${qutebrowser}/bin/qutebrowser";
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
    home.packages = [ qutebrowser ];

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
      package = qutebrowser;
      searchEngines = config.browser.searchEngines;
    };
  };
}
