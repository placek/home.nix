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

    programs.vim = let
      vim-xit = pkgs.vimUtils.buildVimPlugin {
        pname = "xit-vim";
        version = "v0.1.1";
        src = pkgs.fetchFromGitHub {
          owner = "sadotsoy";
          repo = "vim-xit";
          rev = "9b2c60b5da69670e1b8066c3e96bedbe6067699b";
          sha256 = "sha256-edAFJMxIpvkWqRoYB17E7jERyN40heFCBjpeliazRYg=";
        };
      };
    in
    {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-fugitive
        vim-dirvish

        ale
        copilot-vim
        ctrlp-vim
        vim-expand-region
        vim-gitgutter
        vim-xit
      ];
      extraConfig = builtins.readFile ./vimrc;
    };
  };
}
