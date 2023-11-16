{ config
, lib
, pkgs
, ...
}:
{
  config = {
    programs.zathura.enable = true;
    programs.zathura.extraConfig = ''
      unmap q
    '';
    programs.zathura.mappings = {
      "S" = "toggle_statusbar";
    };
    programs.zathura.options = {
      adjust-open = "best-fit";
      font = "${config.gui.font.name} ${builtins.toString config.gui.font.size}";
      guioptions = "";
      pages-per-row = 1;
      recolor = false;
      recolor-keephue = false;
      render-loading = false;
      scroll-full-overlap = "0.01";
      scroll-page-aware = true;
      scroll-step = 50;
      selection-clipboard = "clipboard";
      zoom-min = 10;

      default-bg = config.gui.theme.base00;
      default-fg = config.gui.theme.base05;
      statusbar-fg = config.gui.theme.base05;
      statusbar-bg = config.gui.theme.base00;
      inputbar-bg = config.gui.theme.base00;
      inputbar-fg = config.gui.theme.base05;
      notification-bg = config.gui.theme.base00;
      notification-fg = config.gui.theme.base07;
      notification-error-bg = config.gui.theme.base00;
      notification-error-fg = config.gui.theme.base08;
      notification-warning-bg = config.gui.theme.base00;
      notification-warning-fg = config.gui.theme.base08;
      highlight-color = config.gui.theme.base0A;
      highlight-active-color = config.gui.theme.base0D;
      completion-bg = config.gui.theme.base00;
      completion-fg = config.gui.theme.base0D;
      completion-highlight-fg = config.gui.theme.base07;
      completion-highlight-bg = config.gui.theme.base00;
      recolor-lightcolor = config.gui.theme.base00;
      recolor-darkcolor = config.gui.theme.base06;
    };

    xdg.mimeApps.defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "application/postscript" = [ "org.pwmt.zathura.desktop" ];
      "application/x-cbr" = [ "org.pwmt.zathura.desktop" ];
      "application/x-cbt" = [ "org.pwmt.zathura.desktop" ];
      "image/vnd.djvu" = [ "org.pwmt.zathura.desktop" ];
    };
  };
}
