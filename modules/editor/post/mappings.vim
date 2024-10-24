" LOCALLEADER
nnoremap <localleader><localleader> :CtrlPBuffer<cr>
nnoremap <buffer><localleader>a <plug>(lsp-code-action-float)
nnoremap <buffer><localleader>A <plug>(lsp-document-format)
nnoremap <silent><localleader>b :lmake %:.<cr>
nnoremap <silent><localleader>B :lmake %:. line=<c-r>=line('.')<cr><cr>
nnoremap <silent><localleader>c :G blame<cr>
nnoremap <silent><localleader>C :0GlLog --pretty=oneline<cr>
nnoremap <buffer><localleader>d <plug>(lsp-definition)
nnoremap <buffer><localleader>D <plug>(lsp-type-definition)
nnoremap <silent><localleader>e :Gedit<cr>
nnoremap <buffer><localleader>f <plug>(lsp-references)
nnoremap <silent><localleader>F <plug>(lsp-workspace-symbol-search)
nnoremap <buffer><localleader>i <plug>(lsp-status)
nnoremap <buffer><localleader>r <plug>(lsp-rename)
nnoremap <silent><localleader>q :call <sid>toggleLocList()<cr>
nnoremap <silent><localleader>x :call <sid>altFile()<cr>

vnoremap <buffer> <localleader>A <plug>(lsp-document-range-format)
vnoremap <silent><localleader>f g<c-]>
nnoremap <buffer> K <plug>(lsp-hover-float)
nnoremap <silent>gc :call <sid>commentToggle()<cr>
vnoremap <silent>gc :call <sid>commentToggle()<cr>

" LEADER
nnoremap <silent><leader><leader> :CtrlP<cr>
nnoremap <silent><leader>a <Plug>(TertiusPullRequestWindow)
nnoremap <silent><leader>A <Plug>(TertiusUserStoryWindow)
nnoremap <silent><leader>b :make<cr>
nnoremap <silent><leader>B :make all<cr>
nnoremap <silent><leader>c <Plug>(GitChanges)
nnoremap <silent><leader>C :GcLog --pretty=oneline<cr>
nnoremap <silent><leader>e :edit .<cr>
nnoremap <silent><leader>f <Plug>(GitGrep)
nnoremap <silent><leader>F <Plug>(GitPickaxe)
nnoremap <silent><leader>g <Plug>(GitToggleStatus)
nnoremap <silent><leader>i :echo "Branch-off commit: " . <sid>gitBranchoffCommit()<cr>
nnoremap <silent><leader>n <Plug>(GitCheckoutFromInput)
nnoremap <silent><leader>N <Plug>(GitBranchOffFromCommit)
nnoremap <silent><leader>o :G fetch<cr>
nnoremap <silent><leader>O <Plug>(GitPullAndRebase)
nnoremap <silent><leader>p :G push<cr>
nnoremap <silent><leader>P <Plug>(GitPushForce)
nnoremap <silent><leader>q :call <sid>toggleQuickFix()<cr>
nnoremap <silent><leader>R <Plug>(GitOpen)
nnoremap <silent><leader>t :vertical terminal<cr>
nnoremap <silent><leader>T :terminal<cr>
nnoremap <silent><leader>v :G branch --all<cr>
nnoremap <silent><leader>x <Plug>(TodoToggle)

vnoremap <silent><leader>f <Plug>(GitGrepSelected)
vnoremap <silent><leader>F <Plug>(GitPickaxeSelected)

" movement
nnoremap <buffer> [e <plug>(lsp-previous-diagnostic)
nnoremap <buffer> ]e <plug>(lsp-next-diagnostic)
nnoremap <silent> ]h :GitGutterNextHunk<cr>
nnoremap <silent> [h :GitGutterPrevHunk<cr>

" completion
inoremap <tab> <c-n>

" copilot
inoremap <silent><script><expr> <F11> copilot#Accept("\<cr>")
imap <F10> <Plug>(copilot-previous)
imap <F12> <Plug>(copilot-next)
imap <F9> <Plug>(copilot-suggest)

" expand region
vmap v     <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

" some appearance togglable settings
nnoremap <silent><leader>1 :set relativenumber!<cr>
nnoremap <silent><leader>2 :set hlsearch!<cr>
nnoremap <silent><leader>3 :set spell!<cr>
nnoremap <silent><leader>4 :call <sid>makeFolds()<cr>

" undo sequence for space, dot and newline
inoremap <space> <C-G>u<space>
inoremap . <C-G>u.
inoremap <cr> <C-G>u<cr>

" `<C-p>` that acts like `p`, but not change the `+` register
vnoremap <C-p> "pdp
vnoremap <C-P> "pdP

" right click is an escape
nnoremap <RightMouse> <esc>
inoremap <RightMouse> <esc>
vnoremap <RightMouse> <esc>
cnoremap <RightMouse> <esc>

" move around buffers with leader key
nnoremap <localleader><cr>  :argadd<cr>
nnoremap <localleader><esc> :argdelete<cr>
nnoremap <localleader>h :previous<cr>
nnoremap <localleader>l :next<cr>
nnoremap <localleader>k :bprevious<cr>
nnoremap <localleader>j :bnext<cr>

" move around windows with leader key
nnoremap <silent><leader>h :wincmd h<cr>
nnoremap <silent><leader>l :wincmd l<cr>
nnoremap <silent><leader>k :wincmd k<cr>
nnoremap <silent><leader>j :wincmd j<cr>

" lookup
vnoremap <silent>* :<c-u>call <sid>findTextInBuffer("/", <sid>selectedText())<cr>n
vnoremap <silent># :<c-u>call <sid>findTextInBuffer("#", <sid>selectedText())<cr>n

" remap addition and substraction
nnoremap <A-a> <C-a>
nnoremap <A-x> <C-x>
vnoremap <A-a> <C-a>
vnoremap <A-x> <C-x>
vnoremap g<A-a> g<C-a>
vnoremap g<A-x> g<C-x>
