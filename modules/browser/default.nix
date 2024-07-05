{ config
, lib
, pkgs
, ...
}:
let
  qutebrowser = pkgs.qutebrowser;
in
{
  options = with lib; {
    browserExec = mkOption {
      type = types.str;
      default = "${qutebrowser}/bin/qutebrowser";
      description = "Browser executable.";
      readOnly = true;
    };

    browser = {
      downloadsDirectory = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/Downloads";
        description = "A path to downloads directory.";
      };

      searchEngines = mkOption {
        type = types.attrs;
        default = import ./search-engines.nix;
        description = "Browser search engines.";
        readOnly = true;
      };
    };
  };

  config = {
    home.packages = [ qutebrowser ];

    # backup browser
    programs.firefox.enable = true;

    xdg.desktopEntries.qutebrowser = {
      name = "qutebrowser";
      genericName = "qutebrowser";
      type = "Application";
      exec = config.browserExec;
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

    xdg.configFile."qutebrowser/bookmarks/urls".source = ./bookmarks;
    xdg.configFile."qutebrowser/userscripts/GBrowse" = {
      source = ./GBrowse;
      executable = true;
    };

    programs.qutebrowser = {
      enable = true;
      package = qutebrowser;
      loadAutoconfig = false;
      searchEngines = config.browser.searchEngines;
      keyBindings = import ./key-bindings.nix { inherit (config) terminalExec downloaderExec ytDownloaderExec menuExec; inherit (config.browser) downloadsDirectory; };
      quickmarks = import ./quickmarks.nix;
      extraConfig = builtins.readFile ./extraConfig;
      aliases = import ./aliases.nix;
      settings = import ./settings.nix { inherit (config) terminalExec editorExec fileManagerExec; inherit (config.browser) downloadsDirectory; inherit (config.gui) theme font; };
    };
  };
}
