let
  settings = import ../settings;
  papirusPath = "/usr/share/icons/Papirus-Dark/128x128";
  applicationsPath = "${settings.dirs.home}/.local/share/applications";
in
{
  qtpass-desktop = {
    enable = true;
    target = "${applicationsPath}/qtpass.desktop";
    text = ''
      [Desktop Entry]
      Name=Password management
      Exec=qtpass
      Terminal=false
      Type=Application
      Icon=${papirusPath}/apps/qtpass-icon.svg
    '';
  };

  qutebrowser-desktop = {
    enable = true;
    target = "${applicationsPath}/qutebrowser.desktop";
    text = ''
      [Desktop Entry]
      Name=Web browser
      Exec=qutebrowser-gl
      Terminal=false
      Type=Application
      Icon=${papirusPath}/apps/browser.svg
    '';
  };

  kitty-desktop = {
    enable = true;
    target = "${applicationsPath}/kitty.desktop";
    text = ''
      [Desktop Entry]
      Name=Terminal
      Exec=kitty-gl
      Terminal=false
      Type=Application
      Icon=${papirusPath}/apps/org.gnome.Console.svg
    '';
  };

  qutebrowser-youtube = {
    enable = true;
    target = "${settings.dirs.home}/.config/qutebrowser/greasemonkey/youtube.js";
    text = ''
      let main = new MutationObserver(() => {
        let ad = [...document.querySelectorAll('.ad-showing')][0];
        if (ad) {
          let btn = document.querySelector('.videoAdUiSkipButton,.ytp-ad-skip-button')
          if (btn) {
            btn.click()
          }
        }
      })
      main.observe(document.querySelector('.videoAdUiSkipButton,.ytp-ad-skip-button'), {attributes: true, characterData: true, childList: true})
    '';
  };
}
