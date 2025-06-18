{ config, pkgs, ... }:
{
  services.mako = {
    enable = true;
    font = "${config.gui.font.name} ${builtins.toString config.gui.font.size}";
    backgroundColor = config.gui.theme.base00;
    borderColor = config.gui.theme.base03;
    textColor = config.gui.theme.base0F;
    borderSize = config.gui.border.size;
  };
}
