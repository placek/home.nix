{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    editorExec = mkOption {
      type = types.str;
      default = "${config.programs.neovim.finalPackage}/bin/nvim";
      description = mdDoc "Editor executable.";
      readOnly = true;
    };

    difftoolExec = mkOption {
      type = types.str;
      default = "${config.programs.neovim.finalPackage}/bin/nvim";
      description = mdDoc "Editor executable.";
      readOnly = true;
    };
  };

  config = {
    home.sessionVariables.EDITOR = "vim";
    home.sessionVariables.OPENAI_API_KEY = (import ../../secrets).chatGPT;

    home.packages = with pkgs; [
      fd
      neovim-remote
      ripgrep
      universal-ctags
    ];

    programs.fish.shellAliases.editor = "nvim --listen /tmp/(basename (git root))";

    programs.neovim = {
      enable = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = import ./plugins { inherit pkgs; };
      extraConfig = builtins.readFile ./vimrc;
    };
  };
}
