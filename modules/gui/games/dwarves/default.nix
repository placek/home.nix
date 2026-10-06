{ pkgs
, config
, lib
, ...
}:
let
  inherit (config.gui) theme;

  renderValue = v:
    if lib.isBool v then (if v then "YES" else "NO")
    else if lib.isInt v then toString v
    else if lib.isString v then v
    else throw "dwarves: unsupported setting value ${toString v}";

  # Rewrite [KEY:...] in place, failing the build if the key has disappeared
  # rather than silently dropping the setting.
  setKeys = file: settings:
    lib.concatStrings (lib.mapAttrsToList (key: value: ''
      grep -q '\[${key}:' ${file} || {
        echo "dwarves: no setting named ${key} in ${file}" >&2
        exit 1
      }
      sed -i 's|\[${key}:[^]]*\]|[${key}:${renderValue value}]|' ${file}
    '') settings);

  # colors.txt wants uppercase [NAME_R:int] triples, so turn each base16 hex
  # into its three decimal components.
  toColor = name: hex:
    let
      component = offset: lib.fromHexString (builtins.substring offset 2 hex);
    in
    {
      "${name}_R" = component 1;
      "${name}_G" = component 3;
      "${name}_B" = component 5;
    };

  init = {
    USE_CLASSIC_ASCII = true;

    FONT = "tileset.png";
    FULLFONT = "tileset.png";
    BASIC_FONT = "tileset.png";
    TEXTURE_PARAM = "NEAREST"; # no lanczos blur over 16px tiles

    # The modern interface needs far more room than a classic 80x25; let the
    # game pick a tile scale that fits its desired grid on this screen.
    WINDOWED = false;
    FULLSCREENX = 0;
    FULLSCREENY = 0;
    INTERFACE_SCALING_TO_DESIRED_GRID = true;
    INTERFACE_SCALING_DESIRED_GRID_WIDTH = 170;
    INTERFACE_SCALING_DESIRED_GRID_HEIGHT = 64;

    SOUND = false;
    FPS = false;
  };

  colors = lib.mergeAttrsList [
    (toColor "BLACK" theme.base00)
    (toColor "RED" theme.base01)
    (toColor "GREEN" theme.base02)
    (toColor "BROWN" theme.base03)
    (toColor "BLUE" theme.base04)
    (toColor "MAGENTA" theme.base05)
    (toColor "CYAN" theme.base06)
    (toColor "LGRAY" theme.base07)
    (toColor "DGRAY" theme.base08)
    (toColor "LRED" theme.base09)
    (toColor "LGREEN" theme.base0A)
    (toColor "YELLOW" theme.base0B)
    (toColor "LBLUE" theme.base0C)
    (toColor "LMAGENTA" theme.base0D)
    (toColor "LCYAN" theme.base0E)
    (toColor "WHITE" theme.base0F)
  ];

  # Dwarf Fortress 50+ resolves data/init/* and data/art/* against
  # SDL_GetBasePath(), which is the directory holding the real dwarfort binary.
  # The wrapper's overlay under $XDG_DATA_HOME is never consulted for them, so
  # its `settings` and `theme` arguments have no effect; patch the game package
  # itself, which is what the running binary actually reads.
  game = pkgs.dwarf-fortress-packages.dwarf-fortress-original.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      install -m 0644 ${./tileset.png} $out/data/art/tileset.png
      chmod +w $out/data/init/init_default.txt $out/data/init/colors.txt
      ${setKeys "$out/data/init/init_default.txt" init}
      ${setKeys "$out/data/init/colors.txt" colors}
    '';
  });

  dwarf-fortress = pkgs.dwarf-fortress-packages.dwarf-fortress.override {
    dwarf-fortress = game;
    enableDFHack = true;
    enableStoneSense = false; # a 3D renderer, pointless next to an ASCII grid

    # The wrapper would patch data/init/init.txt, which DF 50+ no longer ships
    # and would not read from the overlay anyway. Leave it be.
    enableIntro = null;
    enableSound = null;
    enableFPS = null;
  };

  # The wrapper installs a vanilla and a DFHack launcher; keep the old command
  # name pointed at the one that actually loads DFHack.
  dwarves = pkgs.writeShellScriptBin "dwarves" ''
    exec ${dwarf-fortress}/bin/dfhack "$@"
  '';
in
{
  config.home.packages = [ dwarf-fortress dwarves ];
}
