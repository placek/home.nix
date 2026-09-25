{ config
, lib
, pkgs
, ...
}:
let
  # Pinned rev (not a floating branch) for reproducibility.
  #
  # main @ 2026-09-25. The binary reports "v0.0.0 (2026.9.24) - upstream
  # 7b761da2": pyproject carries no real version and the date is just the
  # newest tag, so this rev is the only thing that actually identifies a build.
  #
  # Tags exist but lag badly - v2026.9.24 sits ~2150 commits behind main and is
  # older than the rev it replaced - so bump from main rather than from a tag:
  #   gh api repos/NousResearch/hermes-agent/commits/main --jq .sha
  rev = "7b761da2de4979e424510ca7022bf9527aa65b68";

  hermesFlake = builtins.getFlake "github:NousResearch/hermes-agent/${rev}";
in
{
  home.packages = [
    hermesFlake.packages.${pkgs.system}.default

    # The Electron GUI is a separate flake output. `hermes desktop` only knows
    # how to build the app from a source checkout (it looks for
    # apps/desktop/package.json under the CLI's own directory and runs npm
    # there), which no packaged install has. This output builds the renderer
    # and node-pty at Nix build time, wraps nixpkgs' electron around it and
    # points it back at the `hermes` binary above, so the GUI is launched as
    # `hermes-desktop` (also registered as an XDG application entry).
    hermesFlake.packages.${pkgs.system}.desktop
  ];
}
