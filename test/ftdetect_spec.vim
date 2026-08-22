" Filetype detection.

function! s:filetype_of(name) abort
  execute 'silent edit! ' . fnameescape(tempname() . '/' . a:name)
  return &filetype
endfunction

function! Test_detects_known_extensions() abort
  call assert_equal('mermaid', s:filetype_of('a.mmd'), '.mmd')
  call assert_equal('mermaid', s:filetype_of('a.mermaid'), '.mermaid')
  call assert_equal('mermaid', s:filetype_of('a.mm'), '.mm')
endfunction

function! Test_mm_detection_can_be_disabled() abort
  let g:mermaid_detect_mm = 0
  try
    call assert_notequal('mermaid', s:filetype_of('b.mm'), '.mm opt-out')
  finally
    unlet g:mermaid_detect_mm
  endtry
endfunction

function! Test_ftplugin_sets_comment_options() abort
  call Setup(['graph TD'])
  call assert_equal('%% %s', &commentstring, 'commentstring')
  call assert_match('-', &l:iskeyword, 'iskeyword includes dash')
endfunction

function! Test_undo_ftplugin_and_indent_are_defined() abort
  call Setup(['graph TD'])
  call assert_true(exists('b:undo_ftplugin'), 'b:undo_ftplugin')
  call assert_true(exists('b:undo_indent'), 'b:undo_indent')
  call assert_equal('MermaidIndent()', &l:indentexpr, 'indentexpr')
endfunction
