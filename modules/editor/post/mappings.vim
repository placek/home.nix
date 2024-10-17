" LOCALLEADER
nnoremap <localleader><localleader> :CtrlPBuffer<cr>
nnoremap <silent><localleader>a <Plug>(ale_code_action)
nnoremap <silent><localleader>A <Plug>(ale_fix)
nnoremap <silent><localleader>b :lmake %:.<cr>
nnoremap <silent><localleader>B :lmake %:. line=<c-r>=line('.')<cr><cr>
nnoremap <silent><localleader>c :keeppatterns s:<c-r><c-w>:\=substitute(submatch(0), '\(\u\?\l\+\)\(\u\)', '\l\1_\l\2', 'g'):<cr><c-o>
nnoremap <silent><localleader>C :keeppatterns s:<c-r><c-w>:\=substitute(submatch(0),'\(\l\+\)_\?', '\u\1', 'g'):<cr><c-o>
nnoremap <silent><localleader>d <Plug>(ale_go_to_definition_in_vsplit)
nnoremap <silent><localleader>D <Plug>(ale_go_to_type_definition_in_vsplit)
nnoremap <silent><localleader>e :call <sid>commentToggle()<cr>
nnoremap <silent><localleader>f g<c-]>
nnoremap <silent><localleader>F :ALEFindReferences -quickfix \| copen<cr>
nnoremap <silent><localleader>g <Plug>(ale_detail)
nnoremap <silent><localleader>G <Plug>(ale_hover)
nnoremap <silent><localleader>w :call <sid>toggleLocList()<cr>
nnoremap <silent><localleader>s <Plug>(ale_info)
nnoremap <silent><localleader>S <Plug>(ale_toggle)
nnoremap <silent><localleader>v :!<c-r>=&makeprg<cr><cr>
nnoremap <silent><localleader>V :!<c-r>=&makeprg<cr>:<c-r>=line('.')<cr><cr>
nnoremap <silent><localleader>x :call <sid>altFile()<cr>
nnoremap <silent><localleader>y <Plug>(TertiusFixCode)

vnoremap <silent><localleader>f g<c-]>
vnoremap <silent><localleader>y <Plug>(TertiusExplain)

" LEADER
nnoremap <silent><leader><leader> :CtrlP<cr>
nnoremap <silent><leader>a <Plug>(TertiusIssueWindow)
nnoremap <silent><leader>A <Plug>(TertiusPullRequestWindow)
nnoremap <silent><leader>b :G blame<cr>
nnoremap <silent><leader>B :G branch --all<cr>
nnoremap <silent><leader>c :GcLog --pretty=oneline<cr>
nnoremap <silent><leader>C :0GlLog --pretty=oneline<cr>
nnoremap <silent><leader>d <Plug>(GitChanges)
nnoremap <silent><leader>e :Gedit<cr>
nnoremap <silent><leader>f <Plug>(GitGrep)
nnoremap <silent><leader>F <Plug>(GitPickaxe)
nnoremap <silent><leader>g <Plug>(GitToggleStatus)
nnoremap <silent><leader>i :echo "Branch-off commit: " . <sid>branchoffCommit("HEAD")<cr>
nnoremap <silent><leader>n <Plug>(GitCheckoutFromInput)
nnoremap <silent><leader>N <Plug>(GitBranchOffFromCommit)
nnoremap <silent><leader>o :G fetch<cr>
nnoremap <silent><leader>O <Plug>(GitPullAndRebase)
nnoremap <silent><leader>p :G push<cr>
nnoremap <silent><leader>P <Plug>(GitPushForce)
nnoremap <silent><leader>q :call <sid>toggleQuickFix()<cr>
nnoremap <silent><leader>r :edit .<cr>
nnoremap <silent><leader>R <Plug>(GitOpen)
nnoremap <silent><leader>v :vertical terminal<cr>
nnoremap <silent><leader>V :terminal<cr>
nnoremap <silent><leader>x <Plug>(TodoNote)

vnoremap <silent><leader>f <Plug>(GitGrepSelected)
vnoremap <silent><leader>F <Plug>(GitPickaxeSelected)
vnoremap <silent><leader>y <Plug>(TertiusAsk)

" movement
nnoremap <silent> [e <Plug>(ale_previous_wrap)
nnoremap <silent> ]e <Plug>(ale_next_wrap)
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
