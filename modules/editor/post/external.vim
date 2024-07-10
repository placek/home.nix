" source a file under DIRENV_EXTRA_VIMRC environment variable if exists
if !empty($DIRENV_EXTRA_VIMRC) && filereadable($DIRENV_EXTRA_VIMRC)
  source $DIRENV_EXTRA_VIMRC
endif
