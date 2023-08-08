{ pkgs
, ...
}:
pkgs.stdenv.mkDerivation rec {
  pname   = "dcc6502";
  version = builtins.substring 0 6 src.rev;

  src = pkgs.fetchFromGitHub {
    owner  = "tcarmelveilleux";
    repo   = "dcc6502";
    rev    = "680c21299241133449056c2ddfbc0dd087dc3807";
    sha256 = "0vqb56j0790n4b9wm4myab87533yk9gphzjj37dcg3psaqmrsm0k";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp * $out/bin/
  '';
}

