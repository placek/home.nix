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
    background: rgba(0, 0, 0, 0.0);
    border: none;
  }

  #clock,
  #memory,
  #network,
  #disk,
  #pulseaudio,
  #battery,
  #backlight,
  #memory,
  #custom-playnow,
  #custom-notmuch,
  #custom-gpu,
  #cpu {
    background-color: ${config.gui.theme.base00};
    padding: 4px 6px;
    margin-top: 0px;
    margin-left: 6px;
    margin-right: 6px;
    border-width: 0px;
    border-radius: 0px 0px 10px 10px;
  }

  #custom-gpu,
  #memory {
    border-radius: 0px;
    margin: 0px;
  }

  #cpu,
  #custom-playnow {
    border-radius: 0px 0px 0px 10px;
    margin-right: 0px;
  }

  #disk,
  #pulseaudio {
    border-radius: 0px 0px 10px 0px;
    margin-left: 0px;
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
  }

  #workspaces button {
    background-color: ${config.gui.theme.base00};
    color: ${config.gui.theme.base03};
    padding: 6px 12px;
    margin-top: 0px;
    margin-left: 6px;
    margin-right: 6px;
    border-width: 0px;
    border-radius: 10px;
    border: 4px solid ${config.gui.theme.base00};
  }

  #workspaces button.visible {
    border: 4px solid ${config.gui.theme.base08};
  }

  #workspaces button.active {
    border: 4px solid ${config.gui.theme.base03};
  }

  window#waybar #workspaces button:hover,
  window#waybar #workspaces button:hover:active,
  window#waybar #workspaces button:hover:checked,
  window#waybar:backdrop #workspaces button:hover {
    background: ${config.gui.theme.base08};
    border: 4px solid ${config.gui.theme.base08};
    background-image: none;
    box-shadow: none;
  }

  window#waybar #workspaces button:hover > * {
    background: transparent;
  }
  tooltip {
    background: ${config.gui.theme.base00};
    border: 1px solid ${config.gui.theme.base03};
    border-radius: 6px;
    padding: 6px;
    font-size: 12px;
  }
''
