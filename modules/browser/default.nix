{ config
, lib
, ...
}:
let
  sources = import ../../home.lock.nix;
  inherit (sources) pkgs glpkgs;
  qutebrowser-gl = import ./qutebrowser-gl.nix { inherit pkgs glpkgs; };
  mkIfElse = p: yes: no: lib.mkMerge [
    (lib.mkIf p yes)
    (lib.mkIf (!p) no)
  ];
in
{
  options = with lib; {
    browserExec = mkOption {
      type = types.str;
      default =
        if config.gui.enableGL
        then "${qutebrowser-gl}/bin/qutebrowser-gl"
        else "${sources.pkgs.qutebrowser}/bin/qutebrowser";
      description = mdDoc "Browser executable.";
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
    home.packages = lib.mkMerge [
      (lib.mkIf config.gui.enableGL [ qutebrowser-gl ])
      (lib.mkIf (!config.gui.enableGL) [ sources.pkgs.qutebrowser ])
    ];

    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "qutebrowser.desktop" ];
      "x-scheme-handler/http" = [ "qutebrowser.desktop" ];
      "x-scheme-handler/https" = [ "qutebrowser.desktop" ];
    };

    xdg.configFile."qutebrowser/greasemonkey/youtube.js".source = ./youtube.js;
    xdg.configFile."qutebrowser/bookmarks/urls".source = ./bookmarks;
    xdg.configFile."qutebrowser/userscripts/GBrowse" = {
      source = ./GBrowse;
      executable = true;
    };

    programs.qutebrowser = {
      enable = true;
      package = pkgs.qutebrowser-qt6.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.qt6.qtwebengine ];
        postInstall = (oldAttrs.postInstall or "") + ''
          substituteInPlace $out/share/applications/org.qutebrowser.qutebrowser.desktop \
            --replace "Exec=qutebrowser" "Exec=${config.browserExec}" \
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
