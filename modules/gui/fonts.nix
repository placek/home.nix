{ config
, lib
, pkgs
, ...
}:
let
  customFonts = pkgs.stdenv.mkDerivation rec {
    name = "custom-fonts-${version}";
    version = builtins.substring 0 6 src.rev;
    src = pkgs.fetchFromGitHub {
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
  };

  config = {
    home.packages = with pkgs; [
      (pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; })
      customFonts

      ubuntu_font_family
      google-fonts
      font-awesome
    ];
  };
}
