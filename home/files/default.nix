{ pkgs, settings, ... }:
{
  qutebrowser-youtube = {
    enable = true;
    target = "${settings.dirs.home}/.config/qutebrowser/greasemonkey/youtube.js";
    text = ''
      // ==UserScript==
      // @name         Auto Skip YouTube Ads
      // @version      1.0.0
      // @description  Speed up and skip YouTube ads automatically
      // @author       jso8910
      // @match        *://*.youtube.com/*
      // @exclude      *://*.youtube.com/subscribe_embed?*
      // ==/UserScript==
      setInterval(() => {
          const btn = document.querySelector('.videoAdUiSkipButton,.ytp-ad-skip-button')
          if (btn) {
              btn.click()
          }
          const ad = [...document.querySelectorAll('.ad-showing')][0];
          if (ad) {
              document.querySelector('video').playbackRate = 10;
          }
      }, 50)
    '';
  };

  qutebrowser-bookmarks = {
    enable = true;
    target = "${settings.dirs.home}/.config/qutebrowser/bookmarks/urls";
    text = ''
      https://nixos.org/manual/nix/unstable/introduction.html Nix refs
      https://nixos.wiki/wiki/Cheatsheet NixOS cheatsheet
      https://nixos.org/manual/nixos/stable/index.html NixOS man

      https://docs.servant.dev/en/stable/ Servant docs
      https://www.stephendiehl.com/ Shephen Diehl homepage
      https://haskell-at-work.com/episodes.html Haskell at Work
      https://crypto.stanford.edu/~blynn/haskell/ Haskell Fan Site
      https://reflex-frp.org/#try-reflex-frp Reflex FRP
      https://jproyo.github.io/posts/2021-03-17-encoding-effects-freer-simple.html Encoding Effects using freer-simple
      https://hackage.haskell.org/package/polysemy Polysemy Haskell

      https://ergodox-ez.com/pages/oryx-planck Oryx Planck
      https://learnvimscriptthehardway.stevelosh.com/ Vimscript tutor
      https://feed-web.binarapps.com/dashboard BinarFeed
      https://imgflip.com/memegenerator Meme Generator
      http://www.gifntext.com/ Gif&Text

      http://www.ultramontes.pl/index.htm Ultra montes
      http://www.lectionarycentral.com/index.html Traditional lectionary
      https://bibles-online.net/1550/ Stephanus Greek New Testament
      https://spotlight.vatlib.it/greek-paleography/feature/1-majuscule-bookhands Greek paleography
    '';
  };
}
