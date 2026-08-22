" Headless test runner: sources every *_spec.vim and runs its Test_* functions.
" Failures are collected in v:errors (see :help assert_equal).
"
" Output goes through writefile() rather than :echo because Vim's silent ex
" mode (-es) swallows :echo but neovim --headless does not.

let s:dir = expand('<sfile>:p:h')
execute 'source ' . fnameescape(s:dir . '/helpers.vim')

let s:specs = get(g:, 'mermaid_test_specs', '') !=# ''
      \ ? map(split(g:mermaid_test_specs, ','), {_, v -> s:dir . '/' . v})
      \ : sort(glob(s:dir . '/*_spec.vim', 0, 1))

let s:out = []
let s:passed = 0
let s:failed = 0

function! s:test_names() abort
  return sort(map(filter(split(execute('function /^Test_'), "\n"),
        \ {_, v -> v =~# 'Test_'}),
        \ {_, v -> matchstr(v, '\vfunction\s+\zsTest_\w+')}))
endfunction

for s:spec in s:specs
  execute 'source ' . fnameescape(s:spec)
  let s:name = fnamemodify(s:spec, ':t:r')
  for s:fn in s:test_names()
    let v:errors = []
    try
      execute 'call ' . s:fn . '()'
    catch
      call add(v:errors, v:throwpoint . ': ' . v:exception)
    endtry
    if empty(v:errors)
      let s:passed += 1
      call add(s:out, printf('ok   %s  %s', s:name, s:fn))
    else
      let s:failed += 1
      call add(s:out, printf('FAIL %s  %s', s:name, s:fn))
      call extend(s:out, map(copy(v:errors), {_, v -> '       ' . v}))
    endif
  endfor
  " Tests are global functions; drop them so the next spec starts clean.
  for s:fn in s:test_names()
    execute 'delfunction ' . s:fn
  endfor
endfor

call add(s:out, printf('%d passed, %d failed', s:passed, s:failed))
call writefile(s:out, '/dev/stdout')
execute 'cquit!' (s:failed > 0 ? 1 : 0)
