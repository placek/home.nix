{ config
, lib
, pkgs
, ...
}:
let
  # Pinned rev (not a floating branch) for reproducibility.
  # Upstream ships no versioned tag per commit; bump the rev to update.
  # hermes-agent 0.21.5, main @ 2026-09-24.
  rev = "3094b5d0aa611531fa7c197f2495ab86602c2b6d";

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
