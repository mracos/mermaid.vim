au BufNewFile,BufRead *.mm,*.mmd,*.mermaid set filetype=mermaid |
      \ setlocal indentexpr=MermaidIndent() |
      \ setlocal indentkeys+==end,=deactivate
