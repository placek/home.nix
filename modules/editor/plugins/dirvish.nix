{ config
, pkgs
, ...
}:
let
  vim-dirvish-dovish = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-dirvish-dovish";
    version = "04c77b6";
    src = pkgs.fetchFromGitHub {
      owner = "roginfarrer";
      repo = "vim-dirvish-dovish";
      rev = "04c77b6010f7e45e72b4d3c399c120d42f7c5d47";
      sha256 = "sha256-8uw1Ft48JVphhdhd9TBcB3b9NFBRkwdEQH2LZblE1dk=";
    };
  };
in
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.vim-dirvish
      pkgs.vimPlugins.vim-dirvish-git
      vim-dirvish-dovish
    ];

    home.packages = [ pkgs.trashy ];

    editor.RCs = [
      ''
        " do not load shitty netrw
        let g:loaded_netrwPlugin = 1
        let g:loaded_netrw = 1

        hi link DirvishGitModified DiffChange
        hi link DirvishGitStaged DiffAdd
        hi link DirvishGitRenamed DiffChange
        hi link DirvishGitUnmerged DiffChange
        hi link DirvishGitIgnored DiffDelete
        hi link DirvishGitUntracked DiffChange
        hi default link DirvishGitUntrackedDir DirvishPathTail
      ''
    ];
  };
}
