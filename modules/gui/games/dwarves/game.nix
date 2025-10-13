{ pkgs ? import <nixpkgs> {}
}:
{ settings
, colors
}:

let
  inherit (pkgs) stdenv lib fetchurl SDL autoPatchelfHook;
  inherit (lib) getLib;

  dfVersion = "0.47.05";
  url = "https://www.bay12games.com/dwarves/df_47_05_linux.tar.bz2";
  hash = "sha256-rHSm27fX2WIfQwQFCAMiq1DDX2YyNS/y6pI/bcWv/KM=";

  unfuck = pkgs.callPackage (pkgs.path + "/pkgs/games/dwarf-fortress/unfuck.nix") {
    inherit dfVersion;
  };

  renderValue = v:
    if lib.isBool v then
      if v then "YES" else "NO"
    else if lib.isInt v then
      toString v
    else if lib.isPath v then
      builtins.baseNameOf (toString v)
    else if lib.isString v then
      v
    else
      throw "dwarf-fortress-raw: unsupported configuration value ${toString v}";

  renderOption = option: value:
    "[" + (lib.toUpper option) + ":" + (renderValue value) + "]";

  mkSettingsFile = dict:
    lib.concatStringsSep "\n"
      (lib.attrsets.mapAttrsToList (option: value: renderOption option value) dict);

  init_file = pkgs.writeTextFile {
    name = "init.txt";
    text = mkSettingsFile settings;
  };
  colors_file = pkgs.writeTextFile {
    name = "colors.txt";
    text = mkSettingsFile colors;
  };

  game = stdenv.mkDerivation {
    pname = "dwarf-fortress-raw";
    version = dfVersion;
    src = fetchurl { inherit url hash; };
    sourceRoot = ".";
    postUnpack = ''
      mv df_linux/* .
    '';

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ SDL (lib.getLib stdenv.cc.cc) unfuck ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r * $out
      find $out -type d -exec chmod 0755 {} \;
      find $out -type f -exec chmod 0644 {} \;
      chmod +x $out/libs/Dwarf_Fortress
      chmod +x $out/df
      [ -d $out/libs ] && rm -rf $out/libs/*.so $out/libs/*.so.* $out/libs/*.dylib
      rm -rf $out/df_linux
      cp $out/data/art/mouse.png mouse.png
      rm -rf $out/data/art/*
      mv mouse.png $out/data/art/mouse.png
      cp ${settings.font} $out/data/art/${builtins.baseNameOf (toString settings.font)}
      touch $out/data/art/mouse.png
      cp ${init_file} $out/data/init/init.txt
      cp ${colors_file} $out/data/init/colors.txt
      runHook postInstall
    '';
  };
in
  pkgs.writeShellScriptBin "dwarves" ''
    mkdir -p "$XDG_DATA_HOME/dwarves"
    if [ ! -f "$XDG_DATA_HOME/dwarves/df" ]; then
      cp -R ${game}/* "$XDG_DATA_HOME/dwarves"
      chmod +w -R "$XDG_DATA_HOME/dwarves"
    fi
    "$XDG_DATA_HOME/dwarves/df" "$@"
  ''
