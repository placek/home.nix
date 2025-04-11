{ config
, lib
, pkgs
, ...
}:
{
  options.lsp = with lib; {
    efmLangserverConfig = mkOption {
      type = types.path;
      default = pkgs.writeText "efm-langserver-config.yaml" ''
version: 2
root-markers:
  - .git/
lint-debounce: 1s
commands:
  - command: notepad
    arguments:
      - ''${INPUT}
    title: メモ帳

tools:
  any-excitetranslate: &any-excitetranslate
    hover-command: 'excitetranslate'
    hover-stdin: true

  css-prettier: &css-prettier
    format-command: './node_modules/.bin/prettier ''${--tab-width:tabWidth} ''${--single-quote:singleQuote} --parser css'

  csv-csvlint: &csv-csvlint
    lint-command: 'csvlint'

  dockerfile-hadolint: &dockerfile-hadolint
    lint-command: 'hadolint'
    lint-formats:
      - '%f:%l %m'

  gitcommit-gitlint: &gitcommit-gitlint
    lint-command: 'gitlint'
    lint-stdin: true
    lint-formats:
      - '%l: %m: "%r"'
      - '%l: %m'

  html-prettier: &html-prettier
    format-command: './node_modules/.bin/prettier ''${--tab-width:tabWidth} ''${--single-quote:singleQuote} --parser html'

  json-fixjson: &json-fixjson
    format-command: 'fixjson'

  json-jq: &json-jq
    lint-command: 'jq .'

  make-checkmake: &make-checkmake
    lint-command: 'checkmake'
    lint-stdin: true

  markdown-markdownlint: &markdown-markdownlint
    lint-command: 'markdownlint -s -c %USERPROFILE%\.markdownlintrc'
    lint-stdin: true
    lint-formats:
      - '%f:%l %m'
      - '%f:%l:%c %m'
      - '%f: %l: %m'

  markdown-pandoc: &markdown-pandoc
    format-command: 'pandoc -f markdown -t gfm -sp --tab-stop=2'

  mix_credo: &mix_credo
    lint-command: "mix credo suggest --format=flycheck --read-from-stdin ''${INPUT}"
    lint-stdin: true
    lint-formats:
      - '%f:%l:%c: %t: %m'
      - '%f:%l: %t: %m'
    root-markers:
      - mix.lock
      - mix.exs

  sh-shellcheck: &sh-shellcheck
    lint-command: 'shellcheck -f gcc -x'
    lint-source: 'shellcheck'
    lint-formats:
      - '%f:%l:%c: %trror: %m'
      - '%f:%l:%c: %tarning: %m'
      - '%f:%l:%c: %tote: %m'

  sh-shfmt: &sh-shfmt
    format-command: 'shfmt -ci -s -bn'
    format-stdin: true

  vim-vint: &vim-vint
    lint-command: 'vint -'
    lint-stdin: true
    lint-formats:
      - '%f:%l:%c: %m'

  yaml-yamllint: &yaml-yamllint
    lint-command: 'yamllint -f parsable -'
    lint-stdin: true

languages:
  css:
    - <<: *css-prettier

  csv:
    - <<: *csv-csvlint

  dockerfile:
    - <<: *dockerfile-hadolint

  gitcommit:
    - <<: *gitcommit-gitlint

  html:
    - <<: *html-prettier

  json:
    - <<: *json-fixjson
    - <<: *json-jq

  make:
    - <<: *make-checkmake

  markdown:
    - <<: *markdown-markdownlint
    - <<: *markdown-pandoc

  sh:
    - <<: *sh-shellcheck
    - <<: *sh-shfmt

  vim:
    - <<: *vim-vint

  yaml:
    - <<: *yaml-yamllint

  =:
    - <<: *any-excitetranslate
      '';
      description = "efm-langserver config.";
      readOnly = true;
    };
  };

  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.vim-lsp
    ];

    home.packages = [ pkgs.efm-langserver ];

    editor.RCs = [
      ''
        function! LinterStatus() abort
          if !exists('b:lsp')
            return ""
          endif
          let l:counts = lsp#get_buffer_diagnostics_counts()
          let l:total = 0
          for value in values(l:counts)
            let l:total += value
          endfor
          return l:total == 0 ? "OK" : printf('%dE %dW %dH %dI', l:counts.error, l:counts.warning, l:counts.hint, l:counts.information)
        endfunction

        function! s:lspOnBufferEnabled() abort
          setlocal omnifunc=lsp#complete
          setlocal signcolumn=yes
          if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

          let g:lsp_format_sync_timeout = 1000
          let g:lsp_diagnostics_virtual_text_enabled = 1
          let b:lsp = 1
        endfunction

        hi lspReference cterm=underline
        hi LspErrorText ctermbg=0 ctermfg=1
        hi LspErrorHighlight ctermbg=0 ctermfg=1 cterm=underline
        hi LspHintText ctermbg=0 ctermfg=4
        hi LspHintHighlight ctermbg=0 ctermfg=4 cterm=underline
        hi LspWarningText ctermbg=0 ctermfg=3
        hi LspWarningHighlight ctermbg=0 ctermfg=3 cterm=underline
        hi LspInformationText ctermbg=0 ctermfg=8
        hi LspInformationHighlight ctermbg=0 ctermfg=8 cterm=underline

        if executable('efm-langserver')
          au User lsp_setup call lsp#register_server({
            \ 'name': 'efm-langserver',
            \ 'cmd': { server_info->['efm-langserver', '-c=${config.lsp.efmLangserverConfig}'] },
            \ 'allowlist': ['sh', 'make', 'json', 'css', 'html', 'markdown', 'yaml', 'dockerfile', 'gitcommit'],
            \ })
        endif
      ''
    ];
  };
}
