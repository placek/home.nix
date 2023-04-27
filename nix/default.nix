{ pkgs, secrets, ... }:
{
  package = pkgs.nix;
  settings = {
    system-features = [ "big-parallel" "kvm" "benchmark" ];
    access-tokens = secrets.accessTokens;
  };
}
