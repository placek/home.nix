{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    projectsDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Projects";
      description = "A path to project directory.";
    };

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

  imports = [
    ./vim-xit.nix
    ./dovish.nix
  ];

  config = {
    home.sessionVariables.EDITOR = "vim";

    home.packages = with pkgs; [ universal-ctags trashy ];

    programs.fish.shellAliases.editor = "${config.editorExec} --servername (git remote get-url origin | awk -F'[:/]' '{print $(NF-1) \"/\" $(NF)}' | sed 's/\\.git$//')";

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
        vim-terraform
      ];
      extraConfig = builtins.readFile ./vimrc;
    };
  };
}
