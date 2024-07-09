{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.vim-fugitive
    ];

    editor.RCs = [
      ''
        set wildignore+=.git/ " ignore files from git directory

        " Git helpers
        function! s:defaultBranch() abort
          return trim(system("${config.vcsExec} config --get core.default"))
        endfunction

        function! s:branchoffCommit(...) abort
          if a:0 > 0
            let l:head = a:1
          else
            let l:head = "HEAD"
          end
          return trim(system("${config.vcsExec} merge-base " . <sid>defaultBranch() . " " . l:head))
        endfunction

        function! s:whatthecommit() abort
          return trim(system("curl -Ls whatthecommit.com/index.txt"))
        endfunction

        " toggle fugitive status window
        function! s:gitToggleStatus() abort
          if buflisted(bufname('fugitive:///*/.git//$'))
            execute ":bdelete" bufname('fugitive:///*/.git//$')
          else
            Git
            resize 10
            setlocal winfixheight
            setlocal nonumber
            setlocal norelativenumber
          endif
        endfunction

        nnoremap <silent> <Plug>(GitToggleStatus) :<c-u>call <sid>gitToggleStatus()<cr>

        " pickaxe search
        function! s:gitPickaxe(query) abort
          if !empty(a:query)
            execute ":G log -p -G \"" a:query "\""
            call setreg("/", "\\V" . a:query)
          endif
        endfunction

        nnoremap <silent> <Plug>(GitPickaxe) :<c-u>call <sid>gitPickaxe(input("pickaxe /", "", "tag"))<cr>
        vnoremap <silent> <Plug>(GitPickaxeSelected) :call <sid>gitPickaxe(<sid>selectedText())<cr>

        " prune a file in whole git history
        function! s:gitPruneFile(...) abort
          if a:0 > 0
            let l:head = a:1
          else
            let l:head = "HEAD"
          end
          let file = expand("%")
          execute "!${config.vcsExec} filter-branch --prune-empty --force --tree-filter 'rm -f " . l:file . "' " . s:branchoffCommit(l:head) . ".." . l:head
        endfunction

        nnoremap <silent> <Plug>(GitPruneFile) :<c-u>call <sid>gitPruneFile()<cr>

        " make a WIP commit
        function! s:gitWIP() abort
          execute ":G commit --no-verify --message 'WIP " . <sid>whatthecommit() . "'"
        endfunction

        nnoremap <silent> <Plug>(GitWIP) :<c-u>call <sid>gitWIP()<cr>

        " rebase a feature branch
        function! s:gitRebaseBranch(...) abort
          if a:0 > 0
            let l:head = a:1
          else
            let l:head = "HEAD"
          end
          execute ":G rebase --interactive " . <sid>branchoffCommit(l:head)
        endfunction

        nnoremap <silent> <Plug>(GitRebaseBranch) :<c-u>call <sid>gitRebaseBranch()<cr>

        " show changes in a feature branch
        function! s:gitChanges(...) abort
          if a:0 > 0
            let l:head = a:1
          else
            let l:head = "HEAD"
          end
          execute ":Gclog --pretty=oneline " . <sid>branchoffCommit(l:head) . ".." . l:head
        endfunction

        nnoremap <silent> <Plug>(GitChanges) :call <sid>gitChanges()<cr>

        " pull and rebase a feature branch
        function! s:gitPullAndRebase() abort
          G fetch
          execute ":G pull --rebase " . substitute(<sid>defaultBranch(), "/", " ", "")
          echom "Branch rebased to its default branch"
        endfunction

        nnoremap <silent> <Plug>(GitPullAndRebase) :call <sid>gitPullAndRebase()<cr>

        function! s:gitAbsorb() abort
          execute ":G absorb --base " . <sid>branchoffCommit()
        endfunction

        function! s:gitAbsorbAndRebase()
          execute ":G absorb --and-rebase --base " . <sid>branchoffCommit()
        endfunction

        " push with force
        function! s:gitPushForce() abort
          execute ":G push --force-with-lease --follow-tags"
          let l:branch = trim(system("${config.vcsExec} rev-parse --abbrev-ref HEAD"))
          let l:base = substitute(<sid>defaultBranch(), ".*/", "", "")
          echom "Branch pushed"

          if l:branch != l:base
            if confirm("Do you want to open a pull request?", "&yes\n&No", 2) == 1
              normal! \<Plug>(TertiusPullRequestDescriptionWindow)
            endif
          endif
        endfunction

        nnoremap <silent> <Plug>(GitPushForce) :call <sid>gitPushForce()<cr>

        " checkout a branch
        function! s:gitCheckout(branch) abort
          let l:branch = substitute(substitute(a:branch, '^.*\s\+', "", ""), 'remotes/origin/', "", "")
          execute ":G switch " . l:branch
          echom "Switched to " . l:branch
        endfunction

        nnoremap <silent> <Plug>(GitCheckoutFromInput) :<c-u>call <sid>gitCheckout(input("branch /"))<cr>
        nnoremap <silent> <Plug>(GitCheckoutFromLine) :<c-u>call <sid>gitCheckout(trim(getline(".")))<cr>

        " branch off from a current commit
        function! s:gitBranchOffFromCommit() abort
          let l:commit = trim(system("${config.vcsExec} log -1 --pretty=%s"))
          let l:branch_name = trim(substitute(substitute(tolower(l:commit), '[^a-z0-9-]', ' ', 'g'), '\s\+', '-', 'g'))
          let l:branch_name = input("branch /", l:branch_name)
          execute ":G checkout -B " . l:branch_name
        endfunction

        nnoremap <silent> <Plug>(GitBranchOffFromCommit) :call <sid>gitBranchOffFromCommit()<cr>

        " cherry-pick a current commit to a target branch
        function! s:gitCherryPickToBranch(branch) abort
          let l:commit = trim(system("${config.vcsExec} log -1 --pretty=%H"))
          execute ":G switch " . a:branch
          execute ":G pull --rebase"
          execute ":G cherry-pick " . l:commit
        endfunction

        nnoremap <silent> <Plug>(GitCherryPickToBranch) :call <sid>gitCherryPickToBranch(input("branch /"))<cr>

        " triggers a grep on query and opens quickfix list
        function! s:grep(query) abort
          if !empty(a:query)
            execute "silent Ggrep \"" . a:query . "\" | copen"
          endif
        endfunction

        nnoremap <silent> <Plug>(GitFind) :call <sid>find(input("find /", "", "file_in_path"))<cr>
        vnoremap <silent> <Plug>(GitFindSelected) :call <sid>find(<sid>selectedText())<cr>

        " finds a file using git ls-files or find command
        function! s:find(query) abort
          if !empty(a:query)
            execute "silent cexpr system('${config.vcsExec}  ls-files \"**" . a:query . "*\" | sed \"s/.*/&:1:1/\"') | copen"
          endif
        endfunction

        nnoremap <silent> <Plug>(GitGrep) :call <sid>grep(input("grep /", "", "tag"))<cr>
        vnoremap <silent> <Plug>(GitGrepSelected) :call <sid>grep(<sid>selectedText())<cr>

        " standard fugitive commands, autocommands and mappings
        command! -nargs=0 W Gwrite
        command! -nargs=0 E Gedit
        command! -nargs=0 D GDelete
        command! -nargs=0 Gprune call <sid>gitPruneFile()
        command! -nargs=0 Gwip call <sid>gitWIP()
        command! -nargs=0 Grebase call <sid>gitRebaseBranch()
        command! -nargs=0 Gabsorb call <sid>gitAbsorb()
        command! -nargs=0 GabsorbAndRebase call <sid>gitAbsorbAndRebase()

        autocmd! FileType fugitive  nnoremap <buffer> rI <Plug>(GitRebaseBranch)<cr>
        autocmd! FileType gitcommit setlocal spell spelllang=en_us
        autocmd! FileType gitcommit nnoremap <buffer> <cr> <Plug>(TertiusCommitMessage)<cr>
        autocmd! FileType git       nnoremap <buffer> w <Plug>(GitCheckoutFromLine)<cr>
        autocmd! FileType git       nnoremap <buffer> W <Plug>(GitCherryPickToBranch)<cr>

        nnoremap <leader>a :Gabsorb<cr>
        nnoremap <leader>A :GabsorbAndRebase<cr>
        nnoremap <leader>b :G blame<cr>
        nnoremap <leader>B :G branch --all<cr>
        nnoremap <leader>c :GcLog --pretty=oneline<cr>
        nnoremap <leader>C :0GlLog --pretty=oneline<cr>
        nnoremap <leader>d <Plug>(GitChanges)<cr>
        nnoremap <leader>e :Gedit<cr>
        nnoremap <leader>f <Plug>(GitGrep)
        nnoremap <leader>F <Plug>(GitFind)
        nnoremap <leader>g <Plug>(GitToggleStatus)<cr>
        nnoremap <leader>i :echo "Branch-off commit: " . <sid>branchoffCommit("HEAD")<cr>
        nnoremap <leader>I :edit .<cr>
        nnoremap <leader>n <Plug>(GitCheckoutFromInput)<cr>
        nnoremap <leader><C-n> <Plug>(GitBranchOffFromCommit)<cr>
        nnoremap <leader>o :G fetch<cr>
        nnoremap <leader>O <Plug>(GitPullAndRebase)<cr>
        nnoremap <leader>p :G push<cr>
        nnoremap <leader>P :<Plug>(GitPushForce)<cr>
        nnoremap <leader>s <Plug>(GitPickaxe)<cr>

        vnoremap <leader>F <Plug>(GitFindSelected)<cr>
        vnoremap <leader>f <Plug>(GitGrepSelected)<cr>
        vnoremap <leader>s <Plug>(GitPickaxeSelected)<cr>
      ''
    ];
  };
}
