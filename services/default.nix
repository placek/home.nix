{ config, pkgs, ... }:
{
  gpg-agent = import ./gpg-agent;
  mbsync = import ./mbsync { inherit config; };
}
