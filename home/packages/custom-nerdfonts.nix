{ pkgs, settings, ... }:
pkgs.nerdfonts.override { fonts = [ settings.font.name ]; }
