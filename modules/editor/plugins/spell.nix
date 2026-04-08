{ config
, lib
, pkgs
, ...
}:
let
  vimSpellFile = { language, sha256 }:
    pkgs.fetchurl {
      url = "https://ftp.nluug.nl/pub/vim/runtime/spell/${language}.spl";
      inherit sha256;
    };

  polishSpell = vimSpellFile {
    language = "pl.utf-8";
    sha256 = "sha256-FM5QZEzT9p1adhtptZOKbQMYIytctqgB3DTCPaWF5+k=";
  };
in
{
  config = {
    home.file.".config/vim/spell/pl.utf-8.spl".source = polishSpell;
    editor.RCs = [
      ''
        set runtimepath+=~/.config/vim
        set spelllang=pl
        set spell
      ''
    ];
  };
}
