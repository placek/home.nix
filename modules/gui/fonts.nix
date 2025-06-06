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
      rev = "5df129be8ff5c805334656a95e7adc4953d0e35a";
      sha256 = "sha256-sT4XCrcvjRlaXyXCc6qDbONn7pHnxhtDUDf8nhexWPg=";
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
      ubuntu_font_family
      google-fonts
      font-awesome
    ];
  };
}
