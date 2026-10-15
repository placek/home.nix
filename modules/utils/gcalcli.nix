{ config
, lib
, pkgs
, ...
}:

let
  # Google stores two names per calendar list entry: `summary`, the calendar's
  # real name, which only its owner may change, and `summaryOverride`, the
  # private per-user alias the web UI writes when you rename a calendar you
  # cannot rename for real. Both of ours land there: `pawel@kpitech.pl` is
  # shared freeBusyReader-only, and the family calendar's `summary` is managed
  # by Google, which resets it to the localised default.
  #
  # gcalcli 4.5.1 never reads `summaryOverride` — `list`, the `calendar` detail
  # column and `--calendar` matching all go straight to `summary` — so web UI
  # renames are invisible, and the managed family calendar silently drifts.
  # Fold the override into `summary` once inside _get_cached(), covering both
  # the fresh-fetch and the cache-load path, so every consumer agrees on the
  # name shown in the web UI.
  summaryOverride = "for _c in self.all_cals: _c['summary'] = _c.get('summaryOverride') or _c['summary']";

  gcalcli = pkgs.gcalcli.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i \
        -e "s|^\( *\)self\.all_cals = self\.cache\['all_cals'\]$|&\n\1${summaryOverride}|" \
        -e "s|^\( *\)self\.all_cals\.sort(key=lambda x: x\['accessRole'\])$|\1${summaryOverride}\n&|" \
        gcalcli/gcal.py
      test "$(grep -c summaryOverride gcalcli/gcal.py)" = 2
    '';
  });
in
{
  home.packages = [ gcalcli ];

  xdg.configFile."gcalcli/config.toml".text = ''
    [output]
    week-start = "monday"
  '';
}
