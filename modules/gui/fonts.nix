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
      rev = "26fd8728b6a43ec279e5f9146658c93d0d34005e";
      sha256 = "05ykx32lbx3w3s8ph8m06wgnx8wzz07ny0w3fg38lwgzlyjz674q";
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
      (pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; })
      customFonts

      ubuntu_font_family
      google-fonts
      font-awesome
    ];
  };
}
