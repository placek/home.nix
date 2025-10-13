{ pkgs
, config
, lib
, ...
}:
let
  mkDwarfFortress = import ./game.nix { inherit pkgs; };

  toColor = name: hex: let
    r = builtins.substring 1 2 hex;
    g = builtins.substring 3 2 hex;
    b = builtins.substring 5 2 hex;
  in {
    "${name}_r" = lib.fromHexString r;
    "${name}_g" = lib.fromHexString g;
    "${name}_b" = lib.fromHexString b;
  };
in
{
  config.home.packages = [
    (mkDwarfFortress {
      settings = {
        sound = false;
        intro = false;
        windowed = true;
        windowedx = 90;
        windowedy = 30;
        font = ./tileset.png;
        fullfont = ./tileset.png;
        resizable = false;
        black_space = false;
        graphics = false;
        print_mode = "2D";
        single_buffer = false;
        truetype = false;
        topmost = false;
        fps = false;
        mouse = false;
        mouse_picture = false;
      };
      colors = lib.mergeAttrsList [
        (toColor "black" config.gui.theme.base00)
        (toColor "red" config.gui.theme.base01)
        (toColor "green" config.gui.theme.base02)
        { brown_r = 115; brown_g = 87; brown_b = 65; } # override brown
#         (toColor "brown" config.gui.theme.base03)
        (toColor "blue" config.gui.theme.base04)
        (toColor "magenta" config.gui.theme.base05)
        (toColor "cyan" config.gui.theme.base06)
        (toColor "lgray" config.gui.theme.base07)
        (toColor "dgray" config.gui.theme.base08)
        (toColor "lred" config.gui.theme.base09)
        (toColor "lgreen" config.gui.theme.base0A)
        (toColor "yellow" config.gui.theme.base0B)
        (toColor "lblue" config.gui.theme.base0C)
        (toColor "lmagenta" config.gui.theme.base0D)
        (toColor "lcyan" config.gui.theme.base0E)
        (toColor "white" config.gui.theme.base0F)
      ];
    })
  ];
}
