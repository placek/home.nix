{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.ctrlp-vim
    ];

    editor.RCs = [
      ''

        let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:50'
        let g:ctrlp_show_hidden = 1
        let g:ctrlp_map = '<leader><leader>'
        let g:ctrlp_switch_buffer = 'etvh'
        let g:ctrlp_open_multiple_files = '2vjr'
        let g:ctrlp_user_command = {
          \ 'types': {
            \ 1: ['.git', 'cd %s && git ls-files'],
            \ },
          \ 'fallback': 'find %s -type f'
          \ }

        hi link CtrlPMode2 User1
      ''
    ];
  };
}
