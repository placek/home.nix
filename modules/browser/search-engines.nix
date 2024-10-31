{ config
, lib
, ...
}:
{
  options.browser.searchEngines = with lib; mkOption {
    type = types.attrs;
    default = {
      DEFAULT = "https://www.google.com/search?q={}";
      allegro = "https://allegro.pl/listing?string={}";
      alpha = "http://www.wolframalpha.com/input/?i={}";
      ang = "https://context.reverso.net/t%C5%82umaczenie/polski-angielski/{}";
      d = "https://hub.docker.com/search?q={}&type=image";
      duck = "https://duckduckgo.com/?q={}";
      h = "https://hoogle.haskell.org/?hoogle={}";
      hm = "https://home-manager-options.extranix.com/?query={}&release=master";
      m = "http://maps.google.com/maps?q={}";
      nm = "https://nixos.org/manual/nix/stable/introduction.html?search={}";
      np = "https://search.nixos.org/packages?query={}";
      npv = "https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package={}";
      nf = "https://noogle.dev/q?term={}";
      p = "https://getpocket.com/my-list/search?query={}";
      rb = "https://ruby-doc.com/search.html?q={}";
      stack = "https://stackexchange.com/search?q={}";
      we = "https://en.wikipedia.org/wiki/{}";
      wp = "https://pl.wikipedia.org/wiki/{}";
      yt = "https://www.youtube.com/results?search_query={}";
    };
    description = "Browser search engines.";
    readOnly = true;
  };
}
