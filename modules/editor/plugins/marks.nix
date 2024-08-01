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
            if substitute(mark.mark, "'", "", "g") != ""
              execute "sign define Mark" . mark.mark . " text=" . substitute(mark.mark, "'", "", "g") . " texthl=SignColumn"
              call sign_place(0, "marks", "Mark" . mark.mark, bufnr(""), { "lnum": mark.pos[1] })
            endif
          endfor
        endfunction

        autocmd CursorHold * call s:displayMarksInSignColumn()
      ''
    ];
  };
}
