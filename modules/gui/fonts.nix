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
      rev = "f441021aa940621afffa901588af4c180cc745ce";
      sha256 = "1fnskidvnlrr0cgv3rjz6024vhqh1hi81p3dr8var5lrzcpizlgg";
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
