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

        function! s:currentBranch() abort
          return trim(system("${config.vcsExec} rev-parse --abbrev-ref HEAD"))
        endfunction

        function! s:projectName() abort
          let l:url = trim(system('${config.vcsExec} remote get-url origin 2>/dev/null'))
          let l:patterns = [
                \ 'git@[^:]\+:[^/]\+/\([^/]\+\)\.git',
                \ 'https\?://[^/]\+/\([^/]\+\)\.git',
                \ 'git@[^:]\+:[^/]\+/\([^/]\+\)',
                \ 'https\?://[^/]\+/\([^/]\+\)'
                \ ]
          for l:pattern in l:patterns
            let l:matches = matchlist(l:url, l:pattern)
            if len(l:matches) > 0
              return l:matches[1]
            endif
          endfor
          throw 'Unable to extract project name from git remote.'
        endfunction

        function! s:projectOwner() abort
          let l:url = trim(system('${config.vcsExec} remote get-url origin 2>/dev/null'))
          let l:patterns = [
                \ 'git@\([^:]\+\):\([^/]\+\)/[^/]\+\.git',
                \ 'https\?://[^/]\+/\([^/]\+\)/[^/]\+\.git',
                \ 'git@\([^:]\+\):\([^/]\+\)/[^/]\+',
                \ 'https\?://[^/]\+/\([^/]\+\)/[^/]\+'
                \ ]
          for l:pattern in l:patterns
            let l:matches = matchlist(l:url, l:pattern)
            if len(l:matches) > 0
              return l:matches[2]
            endif
          endfor
          throw 'Unable to extract owner from git remote.'
        endfunction

        function! s:gitHostingUrl() abort
          echo getcwd()
          let l:file = expand('%:~:.')
          echo l:file
          let l:owner = <sid>projectOwner()
          let l:repo = <sid>projectName()
          let l:hosting = $GIT_HOSTING ?? 'github'
          echo l:owner . '/' . l:repo . '/blob/' .  <sid>currentBranch() . '/' . l:file
          if l:hosting ==# 'github'
            return 'https://github.com/' .  l:owner . '/' . l:repo . '/blob/' .  <sid>currentBranch() . '/' . l:file
          " elseif l:hosting ==# 'gitlab'
          "   return 'https://gitlab.com/' . l:owner . '/' . l:repo . '/blob/' . <sid>currentBranch() . '/' . l:file
          else
            throw 'Unsupported GIT_HOSTING environment: ' . l:hosting
          endif
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

        " open a file in a git hosting page in branch context
        function! s:openFileInGitHosting() abort
          let l:bufname = bufname('%')
          if !empty(l:bufname) && filereadable(l:bufname)
            silent execute '!${config.browserExec} ' . <sid>gitHostingUrl()
            redraw!
          endif
        endfunction

        nnoremap <silent> <Plug>(GitOpen) :<c-u>call <sid>openFileInGitHosting()<cr>

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

        " prune a file in whole git history
        function! s:gitPruneFile(...) abort
          if a:0 > 0
            let l:head = a:1
          else
            let l:head = "HEAD"
          end
          let l:file = expand("%")
          execute "!${config.vcsExec} filter-branch --prune-empty --force --tree-filter 'rm -f " . l:file . "' " . s:branchoffCommit(l:head) . ".." . l:head
          echom "File " . l:file . " pruned from git history"
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

        nnoremap <silent> <Plug>(GitChanges) :<c-u>call <sid>gitChanges()<cr>

        " pull and rebase a feature branch
        function! s:gitPullAndRebase() abort
          G fetch
          execute ":G pull --rebase " . substitute(<sid>defaultBranch(), "/", " ", "")
          echom "Branch rebased to its default branch"
        endfunction

        nnoremap <silent> <Plug>(GitPullAndRebase) :<c-u>call <sid>gitPullAndRebase()<cr>

        function! s:gitAbsorb() abort
          execute ":G absorb --base " . <sid>branchoffCommit()
        endfunction

        nnoremap <silent> <Plug>(GitAbsorb) :<c-u>call <sid>gitAbsorb()<cr>

        " push with force
        function! s:gitPushForce() abort
          execute ":G push --force-with-lease --follow-tags"
          let l:branch = trim(system("${config.vcsExec} rev-parse --abbrev-ref HEAD"))
          let l:base = substitute(<sid>defaultBranch(), ".*/", "", "")
          echom "Branch pushed with force to " . l:base . " branch

          if l:branch != l:base
            if confirm("Do you want to open a pull request?", "&yes\n&No", 2) == 1
              call <sid>tertiusPullRequestWindow()
            endif
          endif
        endfunction

        nnoremap <silent> <Plug>(GitPushForce) :<c-u>call <sid>gitPushForce()<cr>

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
          echom "Switched to " . l:branch_name
        endfunction

        nnoremap <silent> <Plug>(GitBranchOffFromCommit) :<c-u>call <sid>gitBranchOffFromCommit()<cr>

        " cherry-pick a current commit to a target branch
        function! s:gitCherryPickToBranch(branch) abort
          let l:commit = trim(system("${config.vcsExec} log -1 --pretty=%H"))
          let l:branch = substitute(substitute(a:branch, '^.*\s\+', "", ""), 'remotes/origin/', "", "")
          execute ":G switch " . l:branch
          execute ":G pull --rebase"
          execute ":G cherry-pick " . l:commit
          echom "Cherry-picked commit " . l:commit . " to " . l:branch
        endfunction

        nnoremap <silent> <Plug>(GitCherryPickToBranchFromLine) :<c-u>call <sid>gitCherryPickToBranch(trim(getline(".")))<cr>

        " triggers a grep on query and opens quickfix list
        function! s:gitGrep(query) abort
          if !empty(a:query)
            execute "silent Ggrep \"" . a:query . "\" | copen"
          endif
        endfunction

        nnoremap <silent> <Plug>(GitGrep) :<c-u>call <sid>gitGrep(input("grep /", "", "tag"))<cr>
        vnoremap <silent> <Plug>(GitGrepSelected) :<c-u>call <sid>gitGrep(<sid>selectedText())<cr>

        " pickaxe search
        function! s:gitPickaxe(query) abort
          if !empty(a:query)
            execute ":G log -p -G \"" . a:query . "\""
            call setreg("/", "\\V" . a:query)
          endif
        endfunction

        nnoremap <silent> <Plug>(GitPickaxe) :<c-u>call <sid>gitPickaxe(input("pickaxe /", "", "tag"))<cr>
        vnoremap <silent> <Plug>(GitPickaxeSelected) :<c-u>call <sid>gitPickaxe(<sid>selectedText())<cr>

        " standard fugitive commands, autocommands and mappings
        command! -nargs=0 W Gwrite
        command! -nargs=0 E Gedit
        command! -nargs=0 D Gdelete
        command! -nargs=0 Gprune call <sid>gitPruneFile()
        command! -nargs=0 Gwip call <sid>gitWIP()
        command! -nargs=0 Grebase call <sid>gitRebaseBranch()
      ''
    ];
  };
}
