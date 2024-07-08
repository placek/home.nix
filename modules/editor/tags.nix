{ config
, pkgs
, ...
}:
{
  config = {
    home.packages = [
      pkgs.universal-ctags
    ];

    editor.RCs = [
      ''
        set tags+=.git/tags " add git tags to tag list
        set showfulltag " show info about tag in completemenu

        command! -nargs=0 MakeTags call job_start('git ctags')

        autocmd! BufWritePost * MakeTags

        nnoremap <localleader>f g<c-]>
        vnoremap <localleader>f g<c-]>
      ''
    ];
  };
}
