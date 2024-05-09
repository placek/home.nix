{ pkgs
, ...
}:
pkgs.stdenv.mkDerivation rec {
  pname   = "minipro";
  version = "0.5";

  src = pkgs.fetchFromGitLab {
    owner  = "DavidGriffith";
    repo   = "minipro";
    rev    = "22ec014f6bf0c45741d68d03c99489d0b852ff06";
    sha256 = "sha256-GehSxHSlTPzOUq+YiZYpmGJyQBv0ufJl7CuboBJ+l3M=";
  };

  nativeBuildInputs = with pkgs; [ pkg-config installShellFiles ];
  buildInputs       = with pkgs; [ libusb1 ];

  preConfigure = ''
    export PKG_CONFIG="${pkgs.pkg-config}/bin/pkg-config";
    substituteInPlace Makefile --replace '$(shell date "+%Y-%m-%d %H:%M:%S %z")' "1970-01-01 00:00:00 +0000"
  '';

  makeFlags = [ "-e minipro" ];

  installPhase = ''
    mkdir $out/bin $out/lib/udev/rules.d -pv
    cp -rv ./minipro $out/bin/
    mv udev/* $out/lib/udev/rules.d/ -v
    installManPage ./man/minipro.1
    installShellCompletion --bash ./bash_completion.d/minipro
  '';

  meta = {
    description = "An open source program for controlling the MiniPRO TL866xx series of chip programmers";
    homepage = "https://gitlab.com/DavidGriffith/minipro";
  };
}

