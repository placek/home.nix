{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.vim-fugitive
      pkgs.vimPlugins.vim-gitgutter
    ];

    editor.RCs = [
      ''
        " fugitive
        function! s:toggleFugitive()
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

        function! s:pickaxe(query)
          if !empty(a:query)
            execute ":G log -p -G \"" a:query "\""
            call setreg("/", "\\V" . a:query)
          endif
        endfunction

        function! s:defaultBranch()
          return trim(system("git config --get core.default"))
        endfunction

        function! s:branchoffCommit(...)
          if a:0 > 0
            let l:head = a:1
          else
            let l:head = "HEAD"
          end
          return trim(system("git merge-base " . <sid>defaultBranch() . " " . l:head))
        endfunction

        function! s:whatthecommit()
          return trim(system("curl -Ls whatthecommit.com/index.txt"))
        endfunction

        function! s:gitPruneFile(...)
          if a:0 > 0
            let l:head = a:1
          else
            let l:head = "HEAD"
          end
          let file = expand("%")
          execute "!git filter-branch --prune-empty --force --tree-filter 'rm -f " . l:file . "' " . s:branchoffCommit(l:head) . ".." . l:head
        endfunction

        function! s:gitWIP()
          execute ":G commit --no-verify --message 'WIP " . <sid>whatthecommit() . "'"
        endfunction

        function! s:gitRebaseBranch(...)
          if a:0 > 0
            let l:head = a:1
          else
            let l:head = "HEAD"
          end
          execute ":G rebase --interactive " . <sid>branchoffCommit(l:head)
        endfunction

        function! s:gitChanges(...)
          if a:0 > 0
            let l:head = a:1
          else
            let l:head = "HEAD"
          end
          execute ":Gclog --pretty=oneline " . <sid>branchoffCommit(l:head) . ".." . l:head
        endfunction

        function! s:gitUpdate()
          G fetch
          execute ":G pull --rebase " . substitute(<sid>defaultBranch(), "/", " ", "")
          echom "Branch rebased to its default branch"
        endfunction

        function! s:gitAbsorb()
          execute ":G absorb --base " . <sid>branchoffCommit()
        endfunction

        function! s:gitAbsorbAndRebase()
          execute ":G absorb --and-rebase --base " . <sid>branchoffCommit()
        endfunction

        function! s:gitPush()
          execute ":G push --force-with-lease --follow-tags"
          let l:branch = trim(system("git rev-parse --abbrev-ref HEAD"))
          let l:base = substitute(<sid>defaultBranch(), ".*/", "", "")
          echom "Branch pushed"

          if l:branch != l:base
            if confirm("Do you want to open a pull request?", "&yes\n&No", 2) == 1
              call <sid>oyVeyPullRequestDescription()
            endif
          endif
        endfunction

        function! s:gitCheckout(branch)
          let l:branch = substitute(substitute(a:branch, '^.*\s\+', "", ""), 'remotes/origin/', "", "")
          execute ":G switch " . l:branch
          echom "Switched to " . l:branch
        endfunction

        autocmd FileType git nnoremap <buffer> w :<c-u>call <sid>gitCheckout(trim(getline(".")))<cr>
        nnoremap <leader>n :<c-u>call <sid>gitCheckout(trim(input("branch /")))<cr>

        function! s:branchFromCommit()
          let l:commit = trim(system("git log -1 --pretty=%s"))
          let l:branch_name = trim(substitute(substitute(tolower(l:commit), '[^a-z0-9-]', ' ', 'g'), '\s\+', '-', 'g'))
          let l:branch_name = input("branch /", l:branch_name)
          execute ":G checkout -B " . l:branch_name
        endfunction

        nnoremap <leader><C-n> :<c-u>call <sid>branchFromCommit()<cr>

        function! s:cherryPickToBranch(branch)
          let l:commit = trim(system("git log -1 --pretty=%H"))
          execute ":G switch " . a:branch
          execute ":G pull --rebase"
          execute ":G cherry-pick " . l:commit
        endfunction

        autocmd FileType git nnoremap <buffer> W :<c-u>call <sid>cherryPickToBranch(trim(getline(".")))<cr>

        command! -nargs=0 W Gwrite
        command! -nargs=0 E Gedit
        command! -nargs=0 D GDelete
        command! -nargs=0 Gprune call <sid>gitPruneFile()
        command! -nargs=0 Gwip call <sid>gitWIP()
        command! -nargs=0 Grebase call <sid>gitRebaseBranch()
        command! -nargs=0 Gchanges call <sid>gitChanges()
        command! -nargs=0 Gupdate call <sid>gitUpdate()
        command! -nargs=0 Gabsorb call <sid>gitAbsorb()
        command! -nargs=0 GabsorbAndRebase call <sid>gitAbsorbAndRebase()
        command! -nargs=0 Gpushf call <sid>gitPush()
        command! -nargs=1 -complete=buffer GPickaxe call <sid>pickaxe(<q-args>)

        autocmd! FileType fugitive nnoremap <buffer> rI :<c-u>call <sid>gitRebaseBranch()<cr>
        autocmd! FileType gitcommit setlocal spell spelllang=en_us

        nnoremap <leader>a :Gabsorb<cr>
        nnoremap <leader>A :GabsorbAndRebase<cr>
        nnoremap <leader>b :G blame<cr>
        nnoremap <leader>B :G branch --all<cr>
        nnoremap <leader>i :echo "Branch-off commit: " . <sid>branchoffCommit("HEAD")<cr>
        nnoremap <leader>I :edit .<cr>
        nnoremap <leader>e :Gedit<cr>
        nnoremap <leader>o :G fetch<cr>
        nnoremap <leader>O :Gupdate<cr>
        nnoremap <leader>g :call <sid>toggleFugitive()<cr>
        nnoremap <leader>d :Gchanges<cr>
        nnoremap <leader>C :0GlLog --pretty=oneline<cr>
        nnoremap <leader>c :GcLog --pretty=oneline<cr>
        nnoremap <leader>p :G pull --rebase<cr>
        nnoremap <leader>P :G push<cr>
        nnoremap <leader><c-p> :Gpushf<cr>
        nnoremap <leader>s :call <sid>pickaxe(input("pickaxe /", "", "tag"))<cr>
        vnoremap <leader>s :<c-u>call <sid>pickaxe(<sid>selectedText())<cr>

        " gitgutter
        nnoremap ]h :GitGutterNextHunk<cr>
        nnoremap [h :GitGutterPrevHunk<cr>
      ''
    ];
  };
}
