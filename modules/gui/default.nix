{ config
, lib
, ...
}:
let
  sources = import ../../home.lock.nix;
  customFonts = sources.pkgs.stdenv.mkDerivation rec {
    name = "custom-fonts-${version}";
    version = builtins.substring 0 6 src.rev;
    src = sources.pkgs.fetchFromGitHub {
      owner = "placek";
      repo = "custom-fonts";
      rev = "f4e774280cf9f887fc69552a81cced5c12f9103c";
      sha256 = "sha256-rp4gJuUQz7+ss4zmE8E2RT/C9x7zWs3s9w7Pzs1W7z0=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp -r * $out
    '';
  };
in
{
  options = with lib; {
    gui.theme = mkOption {
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

    gui.font.name = mkOption {
      type = types.str;
      example = "Iosevka Nerd Font";
      description = mdDoc "A name of TTF font.";
    };

    gui.font.size = mkOption {
      type = types.int;
      example = 12;
      description = mdDoc "A font size.";
    };

    gui.enableGL = mkEnableOption "Enable GL engine support for some wayland applications.";

    menuExec = mkOption {
      type = types.str;
      default = "${sources.pkgs.xprompt}/bin/xprompt";
      description = mdDoc "GUI menu executable.";
      readOnly = true;
    };
  };

  config = {
    home.packages = with sources.pkgs; [
      sources.glpkgs.nixGLIntel

      (sources.pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; })
      customFonts

      ubuntu_font_family
      google-fonts
      font-awesome

      xf86_input_wacom
      qtpass
      wl-clipboard
    ];

    xresources = {
      properties = with config.gui.theme; {
        "*foreground" = base0F;
        "*background" = base00;
        "*cursorColor" = base0F;
        "*color0" = base00;
        "*color1" = base01;
        "*color2" = base02;
        "*color3" = base03;
        "*color4" = base04;
        "*color5" = base05;
        "*color6" = base06;
        "*color7" = base07;
        "*color8" = base08;
        "*color9" = base09;
        "*color10" = base0A;
        "*color11" = base0B;
        "*color12" = base0C;
        "*color13" = base0D;
        "*color14" = base0E;
        "*color15" = base0F;

        "*termName" = "xterm-256color";

        "Xft.dpi" = 96;
        "Xft.autohint" = true;
        "Xft.lcdfilter" = "lcdfilter";
        "Xft.hintstyle" = "hintslight";
        "Xft.hinting" = true;
        "Xft.antialias" = true;
        "Xft.rgba" = "rgb";
        "xprompt.font" = config.gui.font.name;
        "xprompt.geometry" = "0x32+0+0";
      };
    };
  };
}
