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

  # 0.47.05 keeps its settings in data/init/init.txt, which predates most of the
  # 50-era keys: there is no USE_CLASSIC_ASCII, no BASIC_FONT and no
  # INTERFACE_SCALING_*. setKeys aborts the build on a key it cannot find, so
  # this list cannot silently drift away from what the game actually reads.
  classicInit = {
    GRAPHICS = false; # 0.47's ASCII switch, standing in for USE_CLASSIC_ASCII

    FONT = "tileset.png";
    FULLFONT = "tileset.png";
    TEXTURE_PARAM = "NEAREST";

    # Defaults to 24, meaning "hand text over to font.ttf once tiles are that
    # tall". A 256x256 tileset stays at 16px and so never trips the threshold,
    # but pinning it off keeps a later tileset swap from quietly replacing every
    # glyph the interface draws.
    TRUETYPE = false;

    # 0.47 has no desired-grid scaling. The zeros take the desktop resolution
    # and the grid simply falls out of it as resolution / 16.
    WINDOWED = false;
    FULLSCREENX = 0;
    FULLSCREENY = 0;

    SOUND = false;
    INTRO = false;
    FPS = false;
  };

  # Both game versions name these identically, down to the ordering, so one
  # palette serves the modern and the classic build alike.
  colors = lib.mergeAttrsList [
    # Not base00. DF only paints cells that hold something and leaves the rest
    # of the window at a hardcoded black, which no init setting, art file or
    # tileset reaches -- on the title screen that is ~87% of the pixels. A
    # themed BLACK therefore only recolours the parts DF does draw, which is
    # what makes menus look like warm panels floating on a black void. Matching
    # the void is the only way to make the two agree.
    (toColor "BLACK" "#000000")
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

    # The wrapper would patch data/init/init.txt, which DF 50+ no longer ships
    # and would not read from the overlay anyway. Leave it be.
    enableIntro = null;
    enableSound = null;
    enableFPS = null;
  };

  # The wrapper names its launcher after the package; keep the old command name.
  dwarves = pkgs.writeShellScriptBin "dwarves" ''
    exec ${dwarf-fortress}/bin/dwarf-fortress "$@"
  '';

  # 0.47 does read its init files out of the overlay, so the wrapper's own
  # settings would reach it -- but patching the package keeps both builds on one
  # mechanism, and the nulls below stop the wrapper undoing these edits on its
  # copy of init.txt.
  classicGame = pkgs.dwarf-fortress-packages.dwarf-fortress_0_47_05.dwarf-fortress.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      install -m 0644 ${./tileset.png} $out/data/art/tileset.png
      chmod +w $out/data/init/init.txt $out/data/init/colors.txt
      ${setKeys "$out/data/init/init.txt" classicInit}
      ${setKeys "$out/data/init/colors.txt" colors}
    '';
  });

  classic = pkgs.dwarf-fortress-packages.dwarf-fortress_0_47_05.override {
    dwarf-fortress = classicGame;

    enableIntro = null;
    enableSound = null;
    enableFPS = null;
  };

  # The wrapper derives its mutable overlay from the platform alone -- every
  # Linux build lands on $XDG_DATA_HOME/df_linux -- so the two versions would
  # otherwise share one directory and interleave incompatible data, raws and
  # saves. Give the classic game a home of its own and leave df_linux to 50+.
  dwarves-old = pkgs.writeShellScriptBin "dwarves-old" ''
    export NIXPKGS_DF_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/df_linux_0.47.05"
    exec ${classic}/bin/dwarf-fortress "$@"
  '';
in
{
  # Only the modern wrapper goes in the profile; both wrappers install
  # bin/dwarf-fortress and would collide. The shims pin their store paths, so
  # the classic build is retained without being on $PATH twice.
  config.home.packages = [ dwarf-fortress dwarves dwarves-old ];
}
