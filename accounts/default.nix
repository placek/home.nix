{ pkgs, settings, ... }:
{
  email = import ./email { inherit pkgs settings; };
}
