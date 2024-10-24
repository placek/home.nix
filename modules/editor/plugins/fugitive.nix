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

        " GIT HELPERS

        " get the default branch of the current git repository
        function! s:gitDefaultBranch() abort
          return trim(system("${config.vcsExec} config --get core.default"))
        endfunction

        " get the current branch of the current git repository
        function! s:gitCurrentBranch() abort
          return trim(system("${config.vcsExec} rev-parse --abbrev-ref HEAD"))
        endfunction

        " sanitize a branch name
        function! s:gitSanitizeBranchName(branch) abort
          return substitute(substitute(a:branch, '^.*\s\+', "", ""), 'remotes/origin/', "", "")
        endfunction

        " get the selected text and format it into a branch name
        function! s:gitBranchNameFromText(text) abort
          return substitute(trim(substitute(tolower(a:text), '[^a-z0-9-]', ' ', 'g')), '\s\+', '-', 'g')
        endfunction

        " get the branch off commit of the current branch
        function! s:gitBranchoffCommit() abort
          return trim(system("${config.vcsExec} merge-base " . <sid>gitDefaultBranch() . " HEAD"))
        endfunction

        " check if commit is empty
        function! s:gitCommitIsEmpty(commit) abort
          return empty(trim(system("${config.vcsExec} show --pretty=format: --name-only " . a:commit)))
        endfunction

        " get commits from the current branch
        function! s:gitCurrentBranchCommits() abort
          return split(system("${config.vcsExec} log --format=%H " . <sid>gitBranchoffCommit() . "..HEAD"), "\n")
        endfunction

        " get last empty commit on the current branch
        function! s:gitLastEmptyCommit() abort
          let l:commits = <sid>gitCurrentBranchCommits()
          for l:commit in l:commits
            if <sid>gitCommitIsEmpty(l:commit)
              return l:commit
            endif
          endfor
        endfunction

        " extract user story id from commit message
        function! s:gitUserStoryId(commit) abort
          let l:commit_message = system("${config.vcsExec} show --pretty=format:%s -s " . a:commit)
          let l:matches = matchlist(l:commit_message, '\[\([^\]]\+\)\]')
          if len(l:matches) > 1
            return l:matches[1]
          endif
          return ""
        endfunction

        nmap <localleader>g :<c-u>echo <sid>gitUserStoryId(<sid>gitLastEmptyCommit())<cr>

        " get the project name from the git remote
        function! s:gitProjectName() abort
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

        " get the project organisation from the git remote
        function! s:gitProjectOrganisation() abort
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

        " VIM FUNCTIONS

        " get the git hosting url of the current file
        function! s:gitHostingUrl() abort
          let l:file = expand('%:~:.')
          let l:owner = <sid>gitProjectOrganisation()
          let l:repo = <sid>gitProjectName()
          let l:hosting = $GIT_HOSTING ?? 'github'
          echo l:owner . '/' . l:repo . '/blob/' .  <sid>gitCurrentBranch() . '/' . l:file
          if l:hosting ==# 'github'
            return 'https://github.com/' .  l:owner . '/' . l:repo . '/blob/' . <sid>gitCurrentBranch() . '/' . l:file
          elseif l:hosting ==# 'gitlab'
            return 'https://gitlab.com/' . l:owner . '/' . l:repo . '/blob/' . <sid>gitCurrentBranch() . '/' . l:file
          else
            throw 'Unsupported GIT_HOSTING environment: ' . l:hosting
          endif
        endfunction

        " open a file in a git hosting page in branch context
        function! s:gitOpenFileInHosting() abort
          let l:bufname = bufname('%')
          if !empty(l:bufname) && filereadable(l:bufname)
            silent execute '!${config.browserExec} ' . <sid>gitHostingUrl()
            redraw!
          endif
        endfunction

        nnoremap <silent> <Plug>(GitOpen) :<c-u>call <sid>gitOpenFileInHosting()<cr>

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
        function! s:gitPruneFile() abort
          let l:file = expand("%")
          execute "!${config.vcsExec} filter-branch --prune-empty --force --tree-filter 'rm -f " . l:file . "' " . <sid>gitBranchoffCommit() . "..HEAD"
          echom "File " . l:file . " pruned from git history"
        endfunction

        nnoremap <silent> <Plug>(GitPruneFile) :<c-u>call <sid>gitPruneFile()<cr>

        " make a WIP commit
        function! s:gitWIP() abort
          execute ":G commit --no-verify --message 'WIP " . trim(system("curl -Ls whatthecommit.com/index.txt")) . "'"
        endfunction

        nnoremap <silent> <Plug>(GitWIP) :<c-u>call <sid>gitWIP()<cr>

        " rebase a feature branch
        function! s:gitRebaseBranch() abort
          execute ":G rebase --interactive " . <sid>gitBranchoffCommit()
        endfunction

        nnoremap <silent> <Plug>(GitRebaseBranch) :<c-u>call <sid>gitRebaseBranch()<cr>

        " show changes in a feature branch
        function! s:gitChanges() abort
          execute ":Gclog --pretty=oneline " . <sid>gitBranchoffCommit() . "..HEAD"
        endfunction

        nnoremap <silent> <Plug>(GitChanges) :<c-u>call <sid>gitChanges()<cr>

        " pull and rebase a feature branch
        function! s:gitPullAndRebase() abort
          G fetch
          execute ":G pull --rebase " . substitute(<sid>gitDefaultBranch(), "/", " ", "")
          echom "Branch rebased to its default branch"
        endfunction

        nnoremap <silent> <Plug>(GitPullAndRebase) :<c-u>call <sid>gitPullAndRebase()<cr>

        function! s:gitAbsorb() abort
          execute ":G absorb --base " . <sid>gitBranchoffCommit()
        endfunction

        nnoremap <silent> <Plug>(GitAbsorb) :<c-u>call <sid>gitAbsorb()<cr>

        " push with force
        function! s:gitPushForce() abort
          execute ":G push --force-with-lease --follow-tags"
          echom "Branch pushed with force to upstream branch."
        endfunction

        nnoremap <silent> <Plug>(GitPushForce) :<c-u>call <sid>gitPushForce()<cr>

        " checkout a branch
        function! s:gitCheckout(branch) abort
          let l:branch = <sid>gitSanitizeBranchName(a:branch)
          execute ":G switch " . l:branch
          echom "Switched to " . l:branch
        endfunction

        nnoremap <silent> <Plug>(GitCheckoutFromInput) :<c-u>call <sid>gitCheckout(input("branch /"))<cr>
        nnoremap <silent> <Plug>(GitCheckoutFromLine) :<c-u>call <sid>gitCheckout(trim(getline(".")))<cr>

        " branch off from a current commit
        function! s:gitBranchOffFromCommit() abort
          let l:commit = trim(system("${config.vcsExec} log -1 --pretty=%s"))
          let l:branch_name = input("branch /", <sid>gitBranchNameFromText(l:commit))
          execute ":G checkout -B " . l:branch_name
          echom "Switched to " . l:branch_name
        endfunction

        nnoremap <silent> <Plug>(GitBranchOffFromCommit) :<c-u>call <sid>gitBranchOffFromCommit()<cr>

        " cherry-pick a current commit to a target branch
        function! s:gitCherryPickToBranch(branch) abort
          let l:commit = trim(system("${config.vcsExec} log -1 --pretty=%H"))
          let l:branch = <sid>gitSanitizeBranchName(a:branch)
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
