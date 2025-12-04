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
      rev = "2d271f1793f662f2d93ecc852abac9b180bac17b";
      sha256 = "sha256-nPsXxEZKc7Auf+EadzVQAgdQUEIvaXu7lSxZUImGDhQ=";
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
      ubuntu-classic
      google-fonts
      font-awesome
    ];
  };
}
