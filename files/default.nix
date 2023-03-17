let
  settings = import ../settings;
in
{
  qutebrowser-desktop = {
    enable = true;
    target = "${settings.dirs.home}/.local/share/applications/qutebrowser.desktop";
    text = ''
      [Desktop Entry]
      Name=Web browser
      Exec=qutebrowser-gl
      Terminal=false
      Type=Application
      Icon=/usr/share/icons/Papirus-Dark/128x128/apps/browser.svg
    '';
  };

  kitty-desktop = {
    enable = true;
    target = "${settings.dirs.home}/.local/share/applications/kitty.desktop";
    text = ''
      [Desktop Entry]
      Name=Terminal
      Exec=kitty
      Terminal=false
      Type=Application
      Icon=/usr/share/icons/Papirus-Dark/128x128/apps/org.gnome.Console.svg
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
