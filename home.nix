{ config
, pkgs
, ...
}:
{
  imports = [
    ./modules/gui
    ./modules/browser
    ./modules/terminal
    ./modules/shell
    ./modules/mux
    ./modules/editor
    ./modules/vcs
    ./modules/security
    ./modules/ssh
    ./modules/mail
    ./modules/utils

    ./settings
  ];
}
