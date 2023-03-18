{
  # pkgs = import (builtins.fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/9e86f5f7a19db6da2445f07bafa6694b556f9c6d.tar.gz"; }) { };
  pkgs = import <nixpkgs> { };
  glpkgs = import (builtins.fetchTarball { url = "https://github.com/guibou/nixGL/archive/main.tar.gz"; }) { };
}
