{ pkgs
, lib
, ...
}:
let
  version = "0.19.0";

  # The *published npm tarball*, not the git tag, and deliberately so: `npm run
  # build` drives scripts/build-viewer.mjs through esbuild ^0.28, nixpkgs 26.05
  # ships esbuild 0.27.2, and esbuild's JS shim aborts when the binary's version
  # does not match the package it was installed for. The tarball already contains
  # the compiled dist/, so taking it skips the build - and the mismatch - whole.
  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@nanonets/graft/-/graft-${version}.tgz";
    hash = "sha256-NuUJY3xYfMkOh0r1NzDcvvvyfSV45ZI35Wz8LI/Cfo4=";
  };

  # That tarball's `files` list is dist/scripts/README/LICENSE only, so it carries
  # no package-lock.json and npm ci has nothing to resolve against. The lock from
  # the matching tag describes exactly the dependency set the tarball's
  # package.json declares, so the two are safe to pair. Keep the two fetches on
  # the same version - a lock from another tag would silently install a different
  # dependency tree underneath the same dist/.
  packageLock = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/trailhq/Graft/v${version}/package-lock.json";
    hash = "sha256-26xsq6Z7eY+5lW3LsTPvKYWonFeSH14lHhu+CsNF91s=";
  };

  graft = pkgs.buildNpmPackage {
    pname = "graft";
    inherit version src;

    postPatch = ''
      cp ${packageLock} package-lock.json
    '';

    # To bump `version`, refresh all three hashes:
    #   nix-prefetch-url https://registry.npmjs.org/@nanonets/graft/-/graft-<v>.tgz
    #   nix-prefetch-url https://raw.githubusercontent.com/trailhq/Graft/v<v>/package-lock.json
    #   nix-shell -p prefetch-npm-deps --run 'prefetch-npm-deps <that lock>'
    # (the first two print base32 - pipe through `nix hash convert --to sri`).
    npmDepsHash = "sha256-egYR4OUbfUQOrPz5JeEb+z6/qjN79mYZPVe063nd8HA=";

    # dist/ ships prebuilt above; there is nothing left to compile.
    dontNpmBuild = true;

    # python3 is for node-gyp, which compiles the grammars that publish no
    # matching prebuild (currently Kotlin and Swift).
    nativeBuildInputs = [ pkgs.python3 pkgs.makeWrapper ];

    # nixpkgs runs `npm ci --ignore-scripts` and then a bare `npm rebuild`, which
    # would execute *every* install script - including tree-sitter-cli's, which
    # unconditionally GETs a release binary from github.com and therefore cannot
    # work in the build sandbox. `npm rebuild <names>` narrows that to the
    # packages that actually need building, turning this list into an allowlist.
    #
    # Skipping tree-sitter-cli costs nothing: it is a prod dependency of
    # tree-sitter-swift only because that grammar's `prestart` runs `tree-sitter
    # build --wasm`, and the grammar ships a pre-generated src/parser.c. Nothing
    # in graft's runtime path ever invokes the CLI.
    #
    # All eight grammars are imported statically at the top of
    # dist/graph/extract.js, so none of them is optional - a missing one is an
    # import error, not a degraded language. tree-sitter-r is an alias for
    # @davisvaughan/tree-sitter-r, and `npm rebuild` matches the real package
    # name rather than the directory, hence the scoped spelling.
    npmRebuildFlags = [
      "tree-sitter"
      "tree-sitter-go"
      "tree-sitter-java"
      "tree-sitter-javascript"
      "tree-sitter-kotlin"
      "tree-sitter-php"
      "tree-sitter-python"
      "tree-sitter-swift"
      "tree-sitter-typescript"
      "@davisvaughan/tree-sitter-r"
    ];

    # npmInstallHook shells out to `npm pack` to learn which files to install,
    # and that fires graft's `prepare` (npm run build && stamp-telemetry-key).
    # The tarball has no tsconfig.json so it fails - and it must not run anyway,
    # per dontNpmBuild above.
    npmPackFlags = [ "--ignore-scripts" ];

    # Unlike a fork or a source build, the published tarball has the PostHog
    # ingestion key baked in (dist/telemetry/key.js), so graft's own default is
    # to report usage to events.nanonets.com. DO_NOT_TRACK is the only gate it
    # honours unconditionally - it outranks even `graft telemetry enable` - so
    # setting it here keeps the decision in this file instead of in per-machine
    # ~/.graft state that a fresh checkout would not carry.
    postFixup = ''
      wrapProgram $out/bin/graft --set DO_NOT_TRACK 1
    '';

    meta = {
      description = "Build a repo's context graph as linked markdown for coding agents";
      homepage = "https://github.com/trailhq/Graft";
      license = lib.licenses.mit;
      mainProgram = "graft";
      platforms = lib.platforms.unix;
    };
  };
in
{
  home.packages = [ graft ];
}
