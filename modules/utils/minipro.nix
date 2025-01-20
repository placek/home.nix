{ pkgs
, ...
}:
pkgs.stdenv.mkDerivation rec {
  pname   = "minipro";
  version = "0.7.2";

  src = pkgs.fetchFromGitLab {
    owner  = "DavidGriffith";
    repo   = "minipro";
    rev    = "8ea3b926a86ff5e2e3111e765d2cccdf5337a8e7";
    sha256 = "sha256-ql2rUVZPAUbBhwpTUhYMVxMeA/kRZBMNIWF05FNFnvU=";
  };

  nativeBuildInputs = with pkgs; [ pkg-config installShellFiles zlib ];
  buildInputs       = with pkgs; [ libusb1 libb64 ];

  preConfigure = ''
    export PKG_CONFIG="${pkgs.pkg-config}/bin/pkg-config";
    substituteInPlace Makefile --replace-warn '$(shell date "+%Y-%m-%d %H:%M:%S %z")' "1970-01-01 00:00:00 +0000"
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

