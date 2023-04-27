{ pkgs, settings, ... }:
{
  qutebrowser-youtube = {
    enable = true;
    target = "${settings.dirs.home}/.config/qutebrowser/greasemonkey/youtube.js";
    text = ''
      let main = new MutationObserver(() => {
        let ad = [...document.querySelectorAll('.ad-showing')][0];
        if (ad) {
          let btn = document.querySelector('.videoAdUiSkipButton,.ytp-ad-skip-button')
          if (btn) { btn.click() }
        }
      })
      main.observe(document.querySelector('.videoAdUiSkipButton,.ytp-ad-skip-button'), {attributes: true, characterData: true, childList: true})
    '';
  };

  qutebrowser-bookmarks = {
    enable = true;
    target = "${settings.dirs.home}/.config/qutebrowser/bookmarks/urls";
    text = ''
      https://docs.servant.dev/en/stable/ Servant documentation
      https://nixos.org/manual/nix/unstable/introduction.html Nix reference
      https://nixos.wiki/wiki/Cheatsheet NixOS cheatsheet
      https://nixos.org/manual/nixos/stable/index.html NixOS - NixOS 21.05 manual
      https://learnvimscriptthehardway.stevelosh.com/ Vimscript tutorial
      https://www.stephendiehl.com/ Shephen Diehl homepage
      https://haskell-at-work.com/episodes.html Episodes | Haskell at Work
      https://crypto.stanford.edu/~blynn/haskell/ Haskell - Haskell Fan Site
      http://www.ultramontes.pl/index.htm Ultra montes
      https://bibles-online.net/1550/ Stephanus Greek New Testament
      https://spotlight.vatlib.it/greek-paleography/feature/1-majuscule-bookhands Greek paleography
      https://imgflip.com/memegenerator Meme Generator
      https://reflex-frp.org/#try-reflex-frp Reflex FRP
      https://jproyo.github.io/posts/2021-03-17-encoding-effects-freer-simple.html Encoding Effects using freer-simple
      https://hackage.haskell.org/package/polysemy Polysemy Haskell
      https://ergodox-ez.com/pages/oryx-planck Oryx Planck
      https://feed-web.binarapps.com/dashboard BinarFeed
      http://www.gifntext.com/ Gif&Text
    '';
  };

  xresources = {
    enable = true;
    target = "${settings.dirs.home}/.Xresources";
    text = ''
      #define base00 ${settings.colors.base00}
      #define base01 ${settings.colors.base01}
      #define base02 ${settings.colors.base02}
      #define base03 ${settings.colors.base03}
      #define base04 ${settings.colors.base04}
      #define base05 ${settings.colors.base05}
      #define base06 ${settings.colors.base06}
      #define base07 ${settings.colors.base07}
      #define base08 ${settings.colors.base08}
      #define base09 ${settings.colors.base09}
      #define base0A ${settings.colors.base0A}
      #define base0B ${settings.colors.base0B}
      #define base0C ${settings.colors.base0C}
      #define base0D ${settings.colors.base0D}
      #define base0E ${settings.colors.base0E}
      #define base0F ${settings.colors.base0F}

      *foreground:     base0F
      *background:     base00
      *cursorColor:    base0F
      *color0:         base00
      *color1:         base01
      *color2:         base02
      *color3:         base03
      *color4:         base04
      *color5:         base05
      *color6:         base06
      *color7:         base07
      *color8:         base08
      *color9:         base09
      *color10:        base0A
      *color11:        base0B
      *color12:        base0C
      *color13:        base0D
      *color14:        base0E
      *color15:        base0F

      *termName:       xterm-256color

      Xft.dpi:         96
      Xft.autohint:    true
      Xft.lcdfilter:   lcdfilter
      Xft.hintstyle:   hintslight
      Xft.hinting:     true
      Xft.antialias:   true
      Xft.rgba:        rgb
      xprompt.font:    ${settings.font.fullName}
      xprompt.geometry 0x32+0+0
    '';
  };
}
