{ config
, lib
, pkgs
, ...
}:
let
  # Pinned rev (not a floating branch) for reproducibility.
  #
  # main @ 2026-10-15. The binary reports "v0.0.0 (2026.9.24) - upstream
  # 450ad505": pyproject carries no real version and the date is just the
  # newest tag, so this rev is the only thing that actually identifies a build.
  #
  # Tags exist but lag badly - v2026.9.24 is still the newest and now sits
  # ~13000 commits behind main - so bump from main rather than from a tag:
  #   gh api repos/NousResearch/hermes-agent/commits/main --jq .sha
  rev = "450ad5055eb3c4852d96676ee99287d618bd283a";

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
