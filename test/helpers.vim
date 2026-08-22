" Assertion helpers shared by the spec files.

" Load `lines` into a scratch mermaid buffer.
function! Setup(lines) abort
  enew!
  setlocal filetype=mermaid
  call setline(1, a:lines)
  " Headless Vim never draws the buffer, so multi-line syntax regions are
  " only resolved correctly when parsing starts from line 1.
  syntax sync fromstart
  return bufnr('%')
endfunction

" Reindent the whole buffer and compare it against the expected lines.
function! AssertIndent(name, input, expected) abort
  call Setup(a:input)
  silent normal! gg=G
  call assert_equal(a:expected, getline(1, '$'), a:name)
endfunction

" Indent of a line opened with `o` under `input`.
" A character has to be typed: leaving insert mode on a whitespace-only line
" makes Vim throw the fresh indent away.
function! AssertNextIndent(name, input, expected) abort
  call Setup(a:input)
  call cursor(len(a:input), 1)
  execute "silent normal! ox\<Esc>"
  call assert_equal(a:expected, indent(line('.')), a:name)
endfunction

" Name of the syntax item under the first occurrence of `pattern`.
" The item name is asserted rather than synIDtrans(), because the standard
" groups collapse (String -> Constant, Keyword -> Statement) and would make
" most of these assertions meaningless.
function! SyntaxGroupAt(lines, lnum, pattern) abort
  call Setup(a:lines)
  let l:col = match(getline(a:lnum), a:pattern) + 1
  if l:col == 0
    call assert_report(printf('pattern %s not found on line %d', a:pattern, a:lnum))
    return ''
  endif
  return synIDattr(synID(a:lnum, l:col, 1), 'name')
endfunction

function! AssertSyntax(name, lines, lnum, pattern, expected) abort
  call assert_equal(a:expected, SyntaxGroupAt(a:lines, a:lnum, a:pattern), a:name)
endfunction
