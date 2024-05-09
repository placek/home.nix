{ pkgs
, ...
}:
pkgs.stdenv.mkDerivation rec {
  pname   = "vasm";
  version = "1.9j";

  src = pkgs.fetchFromGitHub {
    owner  = "StarWolf3000";
    repo   = "vasm-mirror";
    rev    = "e092f8c9fe97f1d850d78e9b790f274eecd4b4ef";
    sha256 = "sha256-ymuS78pcYKRWHRj8PrR1CTKKes16FZ3YIPXxvnOFZ2c=";
  };

  buildInputs = [ pkgs.pkg-config ];
  nativeBuildInputs = [ pkgs.pkg-config ];
  makeFlags = [ "CPU=6502" "SYNTAX=oldstyle" ];
  installPhase = ''
    mkdir -p $out/bin
    cp vasm6502_oldstyle $out/bin/vasm
  '';
}
