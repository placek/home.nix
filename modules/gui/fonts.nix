{ config
, lib
, pkgs
, ...
}:
let
  customFonts = pkgs.stdenv.mkDerivation rec {
    pname = "custom-fonts";
    version = builtins.substring 0 6 src.rev;

    src = pkgs.fetchFromGitHub {
      owner = "placek";
      repo = "custom-fonts";
      rev = "ed1fbd20f79b7753f8974460590537d04574b7d5";
      sha256 = "sha256-MJrp5UXYGhUhHFN3Ex8NCfX6h7teTR0+amtntRx1kuQ=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/fonts

      # fonts from the GitHub repo
      cp -r ./* $out/share/fonts/

      # your extra font file from this repo
      cp ${./grcmnsclix.otf} $out/share/fonts/
    '';
  };
in {
  options = with lib; {
    gui.font.name = mkOption {
      type = types.str;
      example = "Iosevka Nerd Font";
      description = "A name of TTF font.";
    };

    gui.font.size = mkOption {
      type = types.int;
      example = 12;
      description = "A font size.";
    };
  };

  config = {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      customFonts

      nerd-fonts.iosevka
      ubuntu-classic
      google-fonts
      font-awesome

      # Fonts from the custom-fonts repo that have a nixpkgs equivalent.
      # google-fonts (above) already provides: Alex Brush, Allura,
      # Alumni Sans Pinstripe, Amatic SC, Ballet, Beau Rivage, Cookie, Nixie One.
      nasin-nanpa           # nasin-nanpa-4.0.1.otf
      nasin-nanpa-helvetica # nasin-nanpa-4.0.1-Helvetica.otf
      nasin-nanpa-ucsur     # nasin-nanpa-4.0.1-UCSUR.otf
      sitelen-seli-kiwen    # sitelenselikiwenasuki.ttf
      fairfax-hd            # FairfaxHD.ttf
      apl386                # apl385.ttf (APL385 Unicode font, evolved)
    ];
  };
}
