" Vim indent file
" Language:   Mermaid
" URL:        https://github.com/mracos/mermaid.vim

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

let s:cpo_save = &cpoptions
set cpoptions&vim

setlocal indentexpr=MermaidIndent()
setlocal indentkeys=o,O,!^F,0}
" Retrigger the indent when one of these is typed. Only the block keywords and
" the diagram types you would realistically retype mid-buffer are worth the
" cost; the full type list lives in s:diagram_types below.
execute 'setlocal indentkeys+=' . join(map([
      \ 'end', 'else', 'and', 'option', 'deactivate',
      \ 'classDiagram', 'classDiagram-v2', 'erDiagram', 'gantt', 'graph',
      \ 'flowchart', 'pie', 'sequenceDiagram', 'stateDiagram',
      \ 'stateDiagram-v2', 'gitGraph', 'journey', 'mindmap', 'timeline',
      \ 'quadrantChart', 'requirementDiagram', 'kanban', 'block', 'packet',
      \ 'sankey', 'treemap', 'xychart', 'architecture', 'eventmodeling',
      \ ], {_, v -> '=' . v}), ',')

let b:undo_indent = 'setlocal indentexpr< indentkeys<'

" Guard against the file being sourced twice (ftdetect/indent both fire).
if exists('*MermaidIndent')
  let &cpoptions = s:cpo_save
  unlet s:cpo_save
  finish
endif

" Diagram declarations always live at column 0 and open a block. Taken from the
" detector regexes in mermaid's source; several types dropped their `-beta`
" suffix but still accept it, so both spellings are listed. Longest alternative
" first, otherwise `>` ends the match at the dash.
let s:diagram_types =
      \ '\v^\s*(agentflow-beta|architecture-beta|architecture|block-beta|block'
      \ . '|C4Context|C4Container|C4Component|C4Dynamic|C4Deployment'
      \ . '|classDiagram-v2|classDiagram|cynefin-beta|erDiagram|eventmodeling'
      \ . '|flowchart-elk|flowchart|gantt|gitGraph|graph|info|ishikawa-beta'
      \ . '|ishikawa|journey|kanban|mindmap|packet-beta|packet|pie|quadrantChart'
      \ . '|radar-beta|railroad-abnf-beta|railroad-ebnf-beta|railroad-peg-beta'
      \ . '|railroad-beta|requirementDiagram|requirement|sankey-beta|sankey'
      \ . '|sequenceDiagram|stateDiagram-v2|stateDiagram|swimlane-beta|timeline'
      \ . '|treemap-beta|treemap|treeView-beta|usecase-beta|venn-beta'
      \ . '|wardley-beta|xychart-beta|xychart|zenuml)>'

" Diagrams where indentation is the diagram itself, not style: mindmap,
" ishikawa, treemap and treeView nest by indent, and sankey (CSV) and packet
" gain nothing from being reflowed. Never touch any of them.
let s:freeform_types =
      \ '\v^\s*(mindmap|ishikawa-beta|ishikawa|treemap-beta|treemap'
      \ . '|treeView-beta|sankey-beta|sankey|packet-beta|packet|timeline)>'

" Keywords that open a block on the *following* line.
let s:open_keywords =
      \ '\v<(subgraph|loop|alt|else|opt|par|and|rect|critical|option|break|box'
      \ . '|namespace|activate)>'

" Keywords that pull the *current* line back one level.
let s:close_keywords = '\v^(end|else|and|option|deactivate)>'

function! s:strip(line) abort
  " Drop trailing `%%` comments (but not `%%{init}%%` directives) and blanks.
  let l:text = substitute(a:line, '\v\s*\%\%\{.*\}\%\%\s*$', '', '')
  let l:text = substitute(l:text, '\v\s*\%\%[^{].*$', '', '')
  let l:text = substitute(l:text, '\v^\s*\%\%.*$', '', '')
  return substitute(l:text, '\v^\s+|\s+$', '', 'g')
endfunction

function! s:opens_block(text) abort
  if a:text =~# s:diagram_types
    return 1
  endif
  " `class Foo {` / `state Bar {` open a body; `A{Decision}` does not.
  if a:text =~# '\v^(class|namespace|state)>.*\{\s*$'
    return 1
  endif
  return a:text =~# s:open_keywords
endfunction

function! s:closes_block(text) abort
  return a:text =~# s:close_keywords || a:text =~# '\v^[}\]]'
endfunction

" Line number of the first meaningful line, which is what names the diagram.
function! s:diagram_lnum() abort
  let l:in_front_matter = getline(1) ==# '---'
  for l:lnum in range(1, min([line('$'), 50]))
    if l:in_front_matter
      if l:lnum > 1 && getline(l:lnum) ==# '---'
        let l:in_front_matter = 0
      endif
      continue
    endif
    if !empty(s:strip(getline(l:lnum)))
      return l:lnum
    endif
  endfor
  return 0
endfunction

function! MermaidIndent() abort
  let l:current = s:strip(getline(v:lnum))

  " Typing a diagram declaration anywhere snaps it back to column 0. `block:ID`
  " and `requirement r1 {` share their keyword with a declaration but open a
  " block inside one, so a trailing `:` or `{` rules the line out.
  if l:current =~# s:diagram_types && l:current !~# '\v[:{]'
    return 0
  endif

  let l:decl = s:diagram_lnum()
  if l:decl > 0 && s:strip(getline(l:decl)) =~# s:freeform_types
    " Indentation here is data, not style: only seed a fresh line from the
    " line above and never reflow what the author already wrote.
    if !empty(l:current)
      return -1
    endif
    let l:prev = prevnonblank(v:lnum - 1)
    return l:prev == l:decl ? shiftwidth() : indent(l:prev)
  endif

  let l:prev = prevnonblank(v:lnum - 1)
  if l:prev == 0
    return 0
  endif

  let l:indent = indent(l:prev)
  if s:opens_block(s:strip(getline(l:prev)))
    let l:indent += shiftwidth()
  endif
  if s:closes_block(l:current)
    let l:indent -= shiftwidth()
  endif

  return max([l:indent, 0])
endfunction

let &cpoptions = s:cpo_save
unlet s:cpo_save
