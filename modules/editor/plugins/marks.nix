{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        function! s:displayMarksInSignColumn()
          call sign_unplace("marks")
          for mark in getmarklist(bufnr(""))
            let m = substitute(mark.mark, "'", "", "g")
            if m != "" && m != '.' && m != '^'
              execute "sign define Mark" . m . " text=" . m . " texthl=SignColumn"
              call sign_place(0, "marks", "Mark" . m, bufnr(""), { "lnum": mark.pos[1] })
            endif
          endfor
        endfunction

        autocmd CursorHold * call s:displayMarksInSignColumn()
      ''
    ];
  };
}
