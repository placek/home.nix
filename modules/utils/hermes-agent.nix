{ config
, lib
, pkgs
, ...
}:
let
  hermesFlake = builtins.getFlake "github:NousResearch/hermes-agent";
in
{
  home.packages = [
    hermesFlake.packages.${pkgs.system}.default
  ];
}
