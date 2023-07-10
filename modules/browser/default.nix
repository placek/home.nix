{ config
, lib
, ...
}:
let
  sources = import ../../home.lock.nix;
  inherit (sources) pkgs glpkgs;
  qutebrowser-gl = import ./qutebrowser-gl.nix { inherit pkgs glpkgs; };
in
{
  options = with lib; {
    browserExec = mkOption {
      type = types.str;
      default = "${qutebrowser-gl}/bin/qutebrowser-gl";
      description = mdDoc "Terminal executable.";
      readOnly = true;
    };

    browser = {
      downloadsDirectory = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/Downloads";
        description = mdDoc "A path to downloads directory.";
      };
    };
  };

  config = {
    home.packages = [
      qutebrowser-gl
    ];

    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "qutebrowser.desktop" ];
      "x-scheme-handler/http" = [ "qutebrowser.desktop" ];
      "x-scheme-handler/https" = [ "qutebrowser.desktop" ];
    };

    xdg.configFile."qutebrowser/greasemonkey/youtube.js".source = ./youtube.js;
    xdg.configFile."qutebrowser/bookmarks/urls".source = ./bookmarks;

    programs.qutebrowser = {
      enable = true;
      package = pkgs.qutebrowser-qt6.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.qt6.qtwebengine ];
        postInstall = (oldAttrs.postInstall or "") + ''
          substituteInPlace $out/share/applications/org.qutebrowser.qutebrowser.desktop \
            --replace "Exec=qutebrowser" "Exec=qutebrowser-gl" \
            --replace "Icon=qutebrowser" "Icon=browser" \
        '';
      });
      loadAutoconfig = false;
      searchEngines = import ./search-engines.nix;
      keyBindings = import ./key-bindings.nix { inherit (config) terminalExec downloaderExec ytDownloaderExec menuExec; inherit (config.browser) downloadsDirectory; };
      quickmarks = import ./quickmarks.nix;
      extraConfig = builtins.readFile ./extraConfig;
      aliases = import ./aliases.nix;
      settings = import ./settings.nix { inherit (config) terminalExec editorExec fileManagerExec; inherit (config.browser) downloadsDirectory; inherit (config.gui) theme font; };
    };
  };
}
