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

    editor.RCs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of vimrc configuration strings.";
    };
  };

  imports = [
    ./vim-xit.nix
    ./dirvish.nix
  ];

  config = {
    home.sessionVariables.EDITOR = "vim";

    home.packages = [ pkgs.universal-ctags ];

    programs.fish.shellAliases.editor = "${config.editorExec} --servername (git remote get-url origin | awk -F'[:/]' '{print $(NF-1) \"/\" $(NF)}' | sed 's/\\.git$//')";

    editor.RCs = [ (builtins.readFile ./vimrc) ];

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-fugitive

        ale
        copilot-vim
        ctrlp-vim
        vim-expand-region
        vim-gitgutter

        haskell-vim
        vim-terraform
      ];
      extraConfig = lib.strings.concatStringsSep "\n" config.editor.RCs;
    };
  };
}
