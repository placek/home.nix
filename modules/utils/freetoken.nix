{ config
, lib
, pkgs
, ...
}:
let
  # FreeToken is not packageable with buildPythonPackage. Its pyproject pins
  # flashlib==0.3.0, sglang-kernel==0.4.5, apache-tvm-ffi==0.1.13.post3 and
  # flashinfer-python[cu13] to exact prebuilt manylinux wheels served from
  # private indexes (download.pytorch.org/whl/cu130, docs.sglang.io/whl/cu130).
  # None are in nixpkgs and none build from source without rebuilding the whole
  # SGLang/FlashInfer kernel stack against libtorch 2.11.
  #
  # So the split is: the *environment* is declarative (this file), the venv
  # inside it stays imperative uv state. buildFHSEnv gives the wheels the
  # /lib64/ld-linux-x86-64.so.2 they were linked against.

  # home.nix is shared by alpha and omega, and home-manager exposes no hostname
  # option, so read it from the running system. Only alpha (RTX 5080, 123 GiB
  # RAM) can host expert offload; omega is an Optimus laptop and would just pay
  # the ~3 GiB CUDA 13 closure for a tool it cannot run.
  hostname = lib.removeSuffix "\n" (builtins.readFile /etc/hostname);

  # Mutable, not in the nix store, and deliberately outside ~/.local/share:
  # it is regenerable cache-like state, not data worth backing up.
  venvDir = "${config.home.homeDirectory}/.local/state/freetoken/venv";

  # nvcc is needed at *runtime*, not build time: FreeToken JIT-compiles its CUDA
  # kernels on first use. Referenced by store path rather than /usr/bin/nvcc
  # because nvcc finds libdevice via ../nvvm relative to its own binary, and
  # buildFHSEnv only links bin/lib/include/share into /usr - there is no
  # /usr/nvvm for it to walk into.
  cudatoolkit = pkgs.cudaPackages_13.cudatoolkit;

  bootstrap = pkgs.writeShellScript "ft-bootstrap" ''
    set -euo pipefail

    venv="${venvDir}"

    if [ -n "''${FREETOKEN_REINSTALL:-}" ]; then
      echo "ft: FREETOKEN_REINSTALL set, discarding $venv" >&2
      rm -rf "$venv"
    fi

    if [ ! -x "$venv/bin/ft" ]; then
      echo "ft: bootstrapping $venv - this downloads several GiB of CUDA wheels" >&2
      mkdir -p "$(dirname "$venv")"
      # --python python3.13: cp313 is the newest interpreter FreeToken 0.1.2
      # publishes a manylinux wheel for. Letting uv pick would risk a 3.14 that
      # has no wheel and would try (and fail) to build from source.
      uv venv --python python3.13 "$venv"
      VIRTUAL_ENV="$venv" uv pip install "freetoken[accel]"
    fi

    exec "$venv/bin/ft" "$@"
  '';

  freetoken = pkgs.buildFHSEnv {
    name = "ft";

    targetPkgs = pkgs: with pkgs; [
      python313
      uv

      cudatoolkit

      # triton shells out to a real compiler and linker to build its kernels,
      # and the torch wheels want libstdc++ from the same toolchain. ninja is
      # not optional: torch.utils.cpp_extension drives every JIT build through
      # it, so without it `ft bench bw` dies with "No such file or directory:
      # 'ninja'" the moment it tries to compile a real kernel.
      stdenv.cc
      stdenv.cc.cc.lib
      binutils
      cmake
      ninja

      # shared objects the manylinux wheels dlopen or link against
      glib
      libffi
      openssl
      zlib

      # uv resolves git+ dependencies and fetches over TLS
      curl
      git
    ];

    # buildFHSEnv here is the bubblewrap variant, which - unlike the deprecated
    # chroot one - exports only XDG_DATA_DIRS for /run/opengl-driver and leaves
    # its lib/ off the search path. That is where libcuda.so.1 lives, so torch
    # would import cleanly and then fail at the first CUDA call without this.
    profile = ''
      export CUDA_HOME=${cudatoolkit}
      export LD_LIBRARY_PATH=/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    '';

    runScript = bootstrap;
  };
in
{
  config = lib.mkIf (hostname == "alpha") {
    home.packages = [ freetoken ];
  };
}
