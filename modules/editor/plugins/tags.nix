{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        set tags+=.git/tags " add git tags to tag list
        set showfulltag " show info about tag in completemenu

        command! -nargs=0 MakeTags call job_start('${config.ctagsExec}')
      ''
    ];
  };
}
