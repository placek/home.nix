{ config
, lib
, pkgs
, ...
}:
{
  config = {
    home.packages = with pkgs; [ wofi-pass ];

    programs.wofi.enable = true;
    programs.wofi.settings = {
      location = "bottom-right";
      allow_markup = true;
      width = 800;
    };

    programs.wofi.style = ''
      * {
        font-family: "${config.gui.font.name}", "Nerd Font";
        font-size: 16px;
      }

      window {
        background-color: ${config.gui.theme.base00};
        color: ${config.gui.theme.base0F};
        border: 4px solid ${config.gui.theme.base03};
        border-radius: 6px;
      }

      listview {
        padding: 12px;
        spacing: 6px;
      }

      #entry {
        padding: 8px 12px;
        border-radius: 4px;
      }

      #entry,
      #entry:focus,
      #entry:selected,
      #entry:selected:focus {
        border: none !important;
        outline: none !important;
        box-shadow: none !important;
        background-image: none !important;
      }

      #entry:selected {
        background-color: ${config.gui.theme.base03};
        color: ${config.gui.theme.base0F};
        border-radius: 6px;
      }

      scrollbar { background-color: ${config.gui.theme.base01}; }
      scrollbar slider { background-color: ${config.gui.theme.base03}; }

      #input {
        background-color: ${config.gui.theme.base00};
        color: ${config.gui.theme.base0F};
        border: 4px solid ${config.gui.theme.base03};
        border-radius: 6px;
        padding: 4px;
        outline: none;
        box-shadow: none;
      }
    '';
  };
}
