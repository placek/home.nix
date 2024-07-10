{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        function! BlameLineHandler(channel, msg)
          let text = substitute(trim(a:msg), '^\(\w\+\)\s\+(\(.\{-}\)\s\+\d\+).*', ' \1 \2', 'g')
          call prop_remove({ "type": "blame_line" }, 1, line("$"))
          call prop_add(line("."), 0, { "text": l:text, "type": "blame_line", "text_align": "right" })
        endfunc

        function! s:blameLine()
          let line = line('.')
          let file = expand('%')
          let cmd = "${config.vcsExec} blame --date=relative -L" . l:line . "," . l:line . " " . l:file
          call job_start(l:cmd, { "out_cb": "BlameLineHandler" })
        endfunction

        function s:setBlameLine()
          if prop_type_get("blame_line") == {} && trim(system("${config.vcsExec} rev-parse --is-inside-work-tree")) == "true"
            hi BlameLine ctermfg=8
            call prop_type_add("blame_line", { "highlight": "BlameLine" })
            autocmd CursorHold * call <sid>blameLine()
          endif
        endfunction
      ''
    ];
  };
}
