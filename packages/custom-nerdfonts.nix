{ pkgs, ... }:
let
  settings = import ../settings;
in
pkgs.nerdfonts.override { fonts = [ settings.font.name ]; }
