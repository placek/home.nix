augroup Git
  autocmd FileType    fugitive  nnoremap <buffer> rU <Plug>(GitAbsorb)<cr>
  autocmd FileType    fugitive  nnoremap <buffer> rI <Plug>(GitRebaseBranch)<cr>
  autocmd FileType    gitcommit setlocal spell spelllang=en_us
  autocmd FileType    gitcommit nnoremap <buffer> <cr> <Plug>(TertiusCommitMessage)<cr>
  autocmd FileType    gitcommit nnoremap <buffer> n <Plug>(PutTodoNote)<cr>
  autocmd FileType    git       nnoremap <buffer> w <Plug>(GitCheckoutFromLine)<cr>
  autocmd FileType    git       nnoremap <buffer> W <Plug>(GitCherryPickToBranchFromLine)<cr>
  autocmd BufReadPost *         call <sid>setBlameLine()
augroup END

augroup MakePrg
  autocmd BufEnter *_spec.rb  setlocal efm=rspec\ %f:%l\ #\ %m

  autocmd BufEnter *.test.js  setlocal efm=%.%#\ at\ %f:%l:%c,%.%#\ at\ %.%#(%f:%l:%c)
  autocmd BufEnter *.test.ts  setlocal efm=%.%#\ at\ %f:%l:%c,%.%#\ at\ %.%#(%f:%l:%c)
  autocmd BufEnter *.test.jsx setlocal efm=%.%#\ at\ %f:%l:%c,%.%#\ at\ %.%#(%f:%l:%c)
  autocmd BufEnter *.test.tsx setlocal efm=%.%#\ at\ %f:%l:%c,%.%#\ at\ %.%#(%f:%l:%c)
augroup END

augroup AltFile
  autocmd BufReadPost *.rb       call setbufvar(expand('%'), 'altfile', expand('%:.:s/^app/spec/:s/\.rb$/_spec.rb/'))
  autocmd BufReadPost *_spec.rb  call setbufvar(expand('%'), 'altfile', expand('%:.:s/^spec/app/:s/_spec\.rb$/.rb/'))

  autocmd BufReadPost *.js       call setbufvar(expand('%'), 'altfile', expand('%:.:s/\.js$/.test.js/'))
  autocmd BufReadPost *.ts       call setbufvar(expand('%'), 'altfile', expand('%:.:s/\.ts$/.test.ts/'))
  autocmd BufReadPost *.jsx      call setbufvar(expand('%'), 'altfile', expand('%:.:s/\.jsx$/.test.jsx/'))
  autocmd BufReadPost *.tsx      call setbufvar(expand('%'), 'altfile', expand('%:.:s/\.tsx$/.test.tsx/'))
  autocmd BufReadPost *.test.js  call setbufvar(expand('%'), 'altfile', expand('%:.:s/\.test\.js$/.js/'))
  autocmd BufReadPost *.test.ts  call setbufvar(expand('%'), 'altfile', expand('%:.:s/\.test\.ts$/.ts/'))
  autocmd BufReadPost *.test.jsx call setbufvar(expand('%'), 'altfile', expand('%:.:s/\.test\.jsx$/.jsx/'))
  autocmd BufReadPost *.test.tsx call setbufvar(expand('%'), 'altfile', expand('%:.:s/\.test\.tsx$/.tsx/'))
augroup END

autocmd BufWritePost            *  MakeTags
autocmd FileType                qf nnoremap <buffer> <c-v> :call <sid>openQuickfix("vnew")<cr>
autocmd FileType                qf nnoremap <buffer> <c-x> :call <sid>openQuickfix("split")<cr>
autocmd Filetype                qf setlocal statusline=%1*%f%2*
autocmd TerminalWinOpen         *  tmap <esc> <c-\><c-n>
autocmd InsertEnter,InsertLeave *  set cul!
