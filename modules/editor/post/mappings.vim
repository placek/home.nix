" LOCALLEADER
nnoremap <localleader><localleader> :CtrlPBuffer<cr>
nnoremap <silent><localleader>a :LspCodeAction --ui=float<cr>
nnoremap <silent><localleader>A :LspDocumentFormat<cr>
vnoremap <silent><localleader>A :LspDocumentRangeFormat<cr>
nnoremap <silent><localleader>b :lmake %:.<cr>
nnoremap <silent><localleader>B :lmake %:. line=<c-r>=line('.')<cr><cr>
nnoremap <silent><localleader>c :G blame<cr>
nnoremap <silent><localleader>C :0GlLog --pretty=oneline<cr>
nnoremap <silent><localleader>d :LspDefinition<cr>
nnoremap <silent><localleader>D :LspTypeDefinition<cr>
nnoremap <silent><localleader>e :Gedit<cr>
nnoremap <silent><localleader>f :LspReferences<cr>
nnoremap <silent><localleader>F :LspWorkspaceSymbol<cr>
vnoremap <silent><localleader>F :LspWorkspaceSymbolSearch<cr>
nnoremap <silent><localleader>i :LspStatus<cr>
nnoremap <silent><localleader>r :LspRename<cr>
nnoremap <silent><localleader>q :call <sid>toggleLocList()<cr>
nnoremap <silent><localleader>x :call <sid>altFile()<cr>

vnoremap <silent><localleader>f g<c-]>

" LEADER
nnoremap <silent><leader><leader> :CtrlP<cr>
nnoremap <silent><leader>a <Plug>(TertiusPullRequestWindow)
nnoremap <silent><leader>A <Plug>(GitUserStoryWindow)
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
nnoremap <silent><leader>t :vertical terminal<cr>
nnoremap <silent><leader>T :terminal<cr>
nnoremap <silent><leader>v :G branch --all<cr>
nnoremap <silent><leader>x <Plug>(TodoToggle)
nnoremap <silent><leader>z <Plug>(TertiusUserStoryWindow)

vnoremap <silent><leader>f <Plug>(GitGrepSelected)
vnoremap <silent><leader>F <Plug>(GitPickaxeSelected)

" documentation
nnoremap <silent>K :LspHover --ui=float<cr>

" commenting
nnoremap <silent>gc :call <sid>commentToggle()<cr>
vnoremap <silent>gc :call <sid>commentToggle()<cr>

" movement
nnoremap <buffer> [e :LspPreviousDiagnostic<cr>
nnoremap <buffer> ]e :LspNextDiagnostic<cr>
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
nnoremap <leader><cr>  :argadd<cr>
nnoremap <leader><esc> :argdelete<cr>
nnoremap <leader>k :previous<cr>
nnoremap <leader>j :next<cr>
nnoremap <leader>h :bprevious<cr>
nnoremap <leader>l :bnext<cr>

" move around windows
nnoremap <silent><C-h> <C-w>h
nnoremap <silent><C-l> <C-w>l
nnoremap <silent><C-k> <C-w>k
nnoremap <silent><C-j> <C-w>j
tnoremap <silent><C-h> <C-w>h
tnoremap <silent><C-l> <C-w>l
tnoremap <silent><C-k> <C-w>k
tnoremap <silent><C-j> <C-w>j

nnoremap <silent><C-cr> <C-w>v
nnoremap <silent><C-space> <C-w>o
tnoremap <silent><C-cr> <C-w>N:vertical terminal<cr>
tnoremap <silent><C-backspace> <C-w>N

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
