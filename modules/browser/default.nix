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

      theme = mkOption {
        type = with types; submodule {
          options = {
            base00 = mkOption { type = str; };
            base01 = mkOption { type = str; };
            base02 = mkOption { type = str; };
            base03 = mkOption { type = str; };
            base04 = mkOption { type = str; };
            base05 = mkOption { type = str; };
            base06 = mkOption { type = str; };
            base07 = mkOption { type = str; };
            base08 = mkOption { type = str; };
            base09 = mkOption { type = str; };
            base0A = mkOption { type = str; };
            base0B = mkOption { type = str; };
            base0C = mkOption { type = str; };
            base0D = mkOption { type = str; };
            base0E = mkOption { type = str; };
            base0F = mkOption { type = str; };
          };
        };
        description = mdDoc "A color scheme.";
      };

      font.name = mkOption {
        type = types.str;
        default = "Iosevka Nerd Font";
        example = "Iosevka Nerd Font";
        description = mdDoc "A name of TTF font.";
      };

      font.size = mkOption {
        type = types.int;
        default = 12;
        example = 12;
        description = mdDoc "A font size.";
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
      settings = import ./settings.nix { inherit (config) terminalExec editorExec fileManagerExec; inherit (config.browser) downloadsDirectory font theme; };
    };
  };
}
