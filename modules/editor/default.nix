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
      description = "Editor executable.";
      readOnly = true;
    };

    difftoolExec = mkOption {
      type = types.str;
      default = "${config.programs.vim.package}/bin/vimdiff";
      description = "Diff editor executable.";
      readOnly = true;
    };
  };

  config = {
    home.sessionVariables.EDITOR = "vim";

    home.packages = with pkgs; [ universal-ctags ];

    programs.fish.shellAliases.editor = "${config.editorExec} --servername (basename (git root))";

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-fugitive
        vim-dirvish
        vim-dirvish-git

        ale
        copilot-vim
        ctrlp-vim
        vim-expand-region
        vim-gitgutter

        haskell-vim
        (import ./vim-xit.nix { inherit pkgs; })
        (import ./dovish.nix { inherit pkgs; })
      ];
      extraConfig = builtins.readFile ./vimrc;
    };
  };
}
