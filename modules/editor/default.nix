{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    editorExec = mkOption {
      type = types.str;
      default = "${config.programs.vim.package}/bin/vim";
      description = mdDoc "Editor executable.";
      readOnly = true;
    };

    difftoolExec = mkOption {
      type = types.str;
      default = "${config.programs.vim.package}/bin/vim";
      description = mdDoc "Diff editor executable.";
      readOnly = true;
    };
  };

  config = {
    home.sessionVariables.EDITOR = "vim";

    home.packages = with pkgs; [ universal-ctags ];

    programs.fish.shellAliases.editor = "vim --servername (basename (git root))";

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-fugitive
        vim-dirvish

        ale
        copilot-vim
        ctrlp-vim
        vim-expand-region
        vim-gitgutter
      ];
      extraConfig = builtins.readFile ./vimrc;
    };
  };
}
