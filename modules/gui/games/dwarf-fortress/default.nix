{ config
, lib
, pkgs
, ...
}:
let
  dwarf-fortress = pkgs.dwarf-fortress-packages.dwarf-fortress-full.override {
    dfVersion = "0.47.05";
    enableIntro = false;
    enableSound = false;
    enableFPS = false;
    enableDFHack = false;
    enableSoundSense = false;
    enableStoneSense = false;
    enableTWBT = false;
    enableDwarfTherapist = false;
    enableLegendsBrowser = false;
  };
  apply-extras = pkgs.writeShellScriptBin "apply-df-extras" ''
    rm -rf $HOME/.local/share/df_linux/data/init/{colors,init}.txt
    rm -rf $HOME/.local/share/df_linux/data/art
    cp ${./colors.txt} $HOME/.local/share/df_linux/data/init/colors.txt
    cp ${./init.txt} $HOME/.local/share/df_linux/data/init/init.txt
    mkdir -p $HOME/.local/share/df_linux/data/art
    cp ${./tileset.png} $HOME/.local/share/df_linux/data/art/tileset.png
    cp ${./mouse.png} $HOME/.local/share/df_linux/data/art/mouse.png
  '';
in
{
  config = {
    home.packages = [ dwarf-fortress apply-extras ];
  };
}
