" Filetype detection for mermaid diagram files.
"
" *.mm is ambiguous: Vim's own runtime maps it to objcpp/nroff. We keep
" claiming it for backwards compatibility, but it can be disabled with
" `let g:mermaid_detect_mm = 0` in vimrc.

augroup mermaid_ftdetect
  autocmd!
  autocmd BufNewFile,BufRead *.mmd,*.mermaid setlocal filetype=mermaid
  autocmd BufNewFile,BufRead *.mm
        \ if get(g:, 'mermaid_detect_mm', 1) | setlocal filetype=mermaid | endif
augroup END
