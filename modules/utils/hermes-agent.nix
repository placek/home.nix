{ config
, lib
, pkgs
, ...
}:
let
  # Pinned rev (not a floating branch) for reproducibility.
  # Upstream ships no versioned tag per commit; bump the rev to update.
  # hermes-agent 0.20.4, main @ 2026-08-20.
  rev = "a78211b15a4f8733918883eb94cef7a23ebaf30d";

  hermesFlake = builtins.getFlake "github:NousResearch/hermes-agent/${rev}";
in
{
  home.packages = [
    hermesFlake.packages.${pkgs.system}.default
  ];
}
