{ config
, ...
}:
''
  * {
    font-family: ${config.gui.font.name}, "Font Awesome 6 Free", "Font Awesome 6 Free Solid";
    font-weight: bold;
    font-size: 14px;
    color: ${config.gui.theme.base07};
  }

  window#waybar {
    background: ${config.gui.theme.base00};
    border: none;
    margin: 0px;
  }

  #cpu,
  #custom-gpu,
  #memory,
  #disk,
  #network,
  #custom-playnow,
  #pulseaudio,
  #custom-notmuch,
  #clock {
    padding: ${builtins.toString config.gui.border.size}px ${builtins.toString config.gui.border.size}px;
    margin: 0px;
    border-width: 0px;
    border-radius: 0px;
  }

  #network:hover,
  #disk:hover,
  #battery:hover,
  #pulseaudio:hover,
  #custom-temperature:hover,
  #memory:hover,
  #cpu:hover,
  #custom-playnow:hover,
  #custom-gpu:hover,
  #custom-notmuch:hover,
  #clock:hover {
    background-color: ${config.gui.theme.base08};
    color: ${config.gui.theme.base0F};
  }

  #workspaces button {
    background-color: ${config.gui.theme.base00};
    color: ${config.gui.theme.base03};
    padding: ${builtins.toString config.gui.border.size}px ${builtins.toString (config.gui.border.size * 3)}px;
    margin: 0px;
    border-width: 0px;
    border-bottom: ${builtins.toString config.gui.border.size}px solid ${config.gui.theme.base00};
    border-radius: 0px;
  }

  #workspaces button.visible {
    border-bottom: ${builtins.toString config.gui.border.size}px solid ${config.gui.theme.base08};
  }

  #workspaces button.active {
    border-bottom: ${builtins.toString config.gui.border.size}px solid ${config.gui.theme.base03};
  }

  window#waybar #workspaces button:hover {
    background: ${config.gui.theme.base08};
    border-bottom: ${builtins.toString config.gui.border.size}px solid ${config.gui.theme.base08};
    background-image: none;
    box-shadow: none;
    text-shadow: none;
    outline: none;
  }

  window#waybar #workspaces button:hover * {
    color: ${config.gui.theme.base0F};
    box-shadow: none;
    text-shadow: none;
    outline: none;
  }

  window#waybar #workspaces button.active:hover {
    border-bottom: ${builtins.toString config.gui.border.size}px solid ${config.gui.theme.base03};
    box-shadow: none;
    text-shadow: none;
    outline: none;
  }

  window#waybar #workspaces button:hover > * {
    background: transparent;
    box-shadow: none;
    text-shadow: none;
    outline: none;
    color: ${config.gui.theme.base0F};
  }

  tooltip {
    background: ${config.gui.theme.base00};
    padding: ${builtins.toString config.gui.border.size}px;
    border-width: 0px;
    border-radius: 0px;
    box-shadow: none;
    text-shadow: none;
    outline: none;
    font-size: 14px;
    border: ${builtins.toString config.gui.border.size}px solid ${config.gui.theme.base08};
    margin: 0px;
  }
''
