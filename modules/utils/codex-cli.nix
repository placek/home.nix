{ pkgs ? import <nixpkgs> {}
, ...
}:
pkgs.buildNpmPackage rec {
  pname = "codex-cli";
  version = "unstable-${builtins.toString (builtins.currentTime)}";

  src = pkgs.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    rev = "main";
    sha256 = "sha256-WTnP6HZfrMjUoUZL635cngpfvvjrA2Zvm74T2627GwA=";
  };

  # only the codex-cli subdir matters
  sourceRoot = "source/codex-cli";

  nodejs = pkgs.nodejs_22;

  npmDepsHash = "sha256-riVXC7T9zgUBUazH5Wq7+MjU1FepLkp9kHLSq+ZVqbs=";

  meta = with pkgs.lib; {
    description = "OpenAI Codex CLI (from GitHub, codex-cli subdir)";
    homepage = "https://github.com/openai/codex";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
