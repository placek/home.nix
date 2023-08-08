{ pkgs
, ...
}:
pkgs.stdenv.mkDerivation rec {
  pname   = "vasm";
  version = "1.8j";

  src = pkgs.fetchFromGitHub {
    owner  = "mbitsnbites";
    repo   = "vasm-mirror";
    rev    = "2dce5498402353bbe01d74949fe765ee3620d6d5";
    sha256 = "0zrv1fk8ilijdqksg3l0al4yszb1g2ppcp25rjxidrkxyc79zaxr";
  };

  makeFlags = [ "CPU=6502" "SYNTAX=oldstyle" ];
  installPhase = ''
    mkdir -p $out/bin
    cp vasm6502_oldstyle $out/bin/vasm
  '';
}
