""""""""""""""""""""""""""""""""" ESSENTIALS """"""""""""""""""""""""""""""""""<
filetype plugin indent on                                                      " for plugins to load correctly
syntax enable                                                                  " turn on syntax highlighting
set nocompatible                                                               " don't try to be vi compatible

"""""""""""""""""""""""""""""""""" SETTINGS """""""""""""""""""""""""""""""""""<
" interface
set cmdheight=1                                                                " set command line height
set foldcolumn=1                                                               " always show at least one cahr in fold column
set foldmethod=manual
set hlsearch                                                                   " highlight search
set laststatus=2                                                               " always show last status
set noshowmode                                                                 " do not show mode in command line
set showmatch                                                                  " highlight matching brackets
set signcolumn=yes                                                             " always show sign column
set showcmd                                                                    " always show the command opearator
set ruler                                                                      " show file stats
set number                                                                     " show line numbers
set nospell                                                                    " do not display spellchecking
set list listchars=tab:»\ ,nbsp:␣,trail:·,extends:›,precedes:‹                 " show blank characters
set wrap                                                                       " wrap a text on screen
set shortmess+=a shortmess+=c                                                  " shorter messages

" behaviour
set autowrite                                                                  " autosave buffer when using jumps
set backspace=indent,eol,start                                                 " set the behavious of backspace
set clipboard=unnamedplus                                                      " linux standard clipboard
set encoding=utf-8                                                             " encoding
set termencoding=utf-8                                                         " encoding for terminal
set hidden                                                                     " allow hidden buffers
set incsearch                                                                  " show search results while typing regex
set matchpairs+=<:>                                                            " use % to jump between < and > as well
set mouse=a                                                                    " full mouse intagration
set undofile                                                                   " save history of the file
set nobackup                                                                   " no mess in the project
set noswapfile                                                                 " no problematic swap files
set undodir=/tmp/undodir                                                       " set the directory for undofiles

" completion
set omnifunc=syntaxcomplete#Complete                                           " set onmicomplete function
set completeopt=menuone,noselect                                               " on completion always show menu, but do not select anything

" diff options
set diffopt+=algorithm:minimal                                                 " most minimal diff possible
set diffopt+=indent-heuristic                                                  " indentation
set diffopt-=internal                                                          " don't use internal diff algorithm

" more natural splits
set splitbelow                                                                 " split below to current window
set splitright                                                                 " split right to current window

" indentation
set noshiftround                                                               " do not round indent to multiple of 2
set shiftwidth=2                                                               " indent size

" tabs into space
set expandtab                                                                  " tabs into spaces
set softtabstop=2                                                              " width of the tab in spaces
set tabstop=2                                                                  " tabs at 2 spaces

" text width
set textwidth=80                                                               " 80 columns wide text
set colorcolumn=80,160                                                         " a bar at 80 and 160 column

" gotta go fast!
set updatetime=300                                                             " CursorHold delay
set timeoutlen=1000 ttimeoutlen=0                                              " immediate escape key result
set ttyfast                                                                    " fast rendering

" autocomplete paths in command mode
set path+=**                                                                   " search down files into subdirectories
set wildmenu                                                                   " display all matching files on tab completion
set wildignore+=**/node_modules/**                                             " ignore files from unwanted directories
set wildmode=longest:full,full                                                 " match longest path fully matching pattern

" status line
set statusline=%1*\ %{toupper(mode())}\ %2*\ %F:%l:%c%=
set statusline+=\ %Y\ %{LinterStatus()}\ %1*\ %m%r[%n]\ %{strlen(&fenc)?&fenc:'none'}\ 

""""""""""""""""""""""""""""""""""" LEADERS """""""""""""""""""""""""""""""""""<
let g:mapleader      = "\<space>"                                              " main leader set to space
let g:maplocalleader = "\<backspace>"                                          " local leader set to comma

"""""""""""""""""""""""""""""""""""" COLORS """""""""""""""""""""""""""""""""""<
hi ColorColumn  ctermbg=8
hi CtrlPMode1   ctermbg=0  ctermfg=3
hi DiffAdd      ctermbg=8  ctermfg=10 cterm=none
hi DiffChange   ctermbg=8  ctermfg=3  cterm=none
hi DiffDelete   ctermbg=8  ctermfg=9  cterm=none
hi DiffText     ctermbg=8  ctermfg=11 cterm=underline
hi Directory               ctermfg=4
hi FoldColumn   ctermbg=0  ctermfg=7
hi Folded       ctermbg=0  ctermfg=7  cterm=bold
hi NormalFloat  ctermbg=0
hi Pmenu        ctermbg=0  ctermfg=7
hi PmenuSbar    ctermbg=0  ctermfg=7
hi PmenuSel     ctermbg=8  ctermfg=15
hi QuickFixLine ctermbg=8
hi Search       ctermbg=8  ctermfg=11 cterm=bold
hi SignColumn   ctermbg=0
hi SpellBad     ctermbg=8  ctermfg=9  cterm=underline
hi StatusLine                         cterm=bold
hi StatusLineNC ctermbg=0  ctermfg=0  cterm=none
hi TabLine      ctermbg=8  ctermfg=7  cterm=none
hi User1        ctermbg=3  ctermfg=0  cterm=bold
hi User2        ctermbg=0  ctermfg=15 cterm=bold
hi VertSplit    ctermbg=8  ctermfg=8
hi Visual       ctermbg=7  ctermfg=0

hi link TabLineFill StatusLineNC
hi link TabLineSel User1
hi link SpellCap SpellBad
hi link SpellLocal SpellBad

" variable name
hi! Identifier   ctermfg=12 cterm=none
" function name
hi! Function     ctermfg=2  cterm=none
" generic preprocessor
hi! PreProc      ctermfg=5  cterm=none
" preprocessor #include
hi! Include      ctermfg=5  cterm=none
" preprocessor #define
hi! Define       ctermfg=5  cterm=bold
" same as define
hi! Macro        ctermfg=5  cterm=none
" preprocessor #if, #else, #endif, etc.
hi! PreCondit    ctermfg=5  cterm=none
" generic statement
hi! Statement    ctermfg=4  cterm=bold
" if, then, else, endif, swicth, etc.
hi! Conditional  ctermfg=4  cterm=bold
" for, do, while, etc.
hi! Repeat       ctermfg=4  cterm=bold
" case, default, etc.
hi! Label        ctermfg=4  cterm=bold
" try, catch, throw
hi! Exception    ctermfg=4  cterm=bold
" sizeof, "+", "*", etc.
hi! Operator     ctermfg=14 cterm=bold
" any other keyword
hi! Keyword      ctermfg=4  cterm=bold
" generic type
hi! Type         ctermfg=2  cterm=bold
" static, register, volatile, etc
hi! StorageClass ctermfg=2  cterm=none
" struct, union, enum, etc.
hi! Structure    ctermfg=2  cterm=none
" typedef
hi! Typedef      ctermfg=2  cterm=none
" character constant: 'c', '/n'
hi! Character    ctermfg=3  cterm=none
" string constant: "this is a string"
hi! String       ctermfg=3  cterm=none
" generic comment
hi! Comment      ctermfg=8  cterm=none
" generic constant
hi! Constant     ctermfg=7  cterm=none
" boolean constant: TRUE, false
hi! Boolean      ctermfg=7  cterm=bold
" number constant: 234, 0xff
hi! Number       ctermfg=7  cterm=bold
" floating point constant: 2.3e10
hi! Float        ctermfg=7  cterm=bold

"""""""""""""""""""""""""""""""""""" UTILS """"""""""""""""""""""""""""""""""""
" use `open` command to open a current buffer
command! -nargs=0 Open !open %

" leave only the current buffer - delete others
command! -nargs=0 BufOnly execute '%bdelete|edit #|normal `"'
