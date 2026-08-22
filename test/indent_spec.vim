" Indent behaviour.

function! Test_indents_body_of_a_graph() abort
  call AssertIndent('graph body',
        \ ['graph TD', 'A --> B', 'B --> C'],
        \ ['graph TD', '  A --> B', '  B --> C'])
endfunction

function! Test_indents_subgraph_and_dedents_end() abort
  call AssertIndent('subgraph',
        \ ['graph LR', 'subgraph one', 'a --> b', 'end', 'c --> d'],
        \ ['graph LR', '  subgraph one', '    a --> b', '  end', '  c --> d'])
endfunction

" Regression: blank lines used to reset the indent to column 0.
function! Test_blank_lines_inside_a_graph_keep_the_level() abort
  call AssertIndent('blank line',
        \ ['graph TD', 'A --> B', '', 'B --> C'],
        \ ['graph TD', '  A --> B', '', '  B --> C'])
endfunction

" Regression: `else`/`and` opened a block but never closed one, so every
" branch of an alt drifted one level further right.
function! Test_alt_else_end_stay_on_the_same_level() abort
  call AssertIndent('alt/else',
        \ ['sequenceDiagram', 'alt is ok', 'A->>B: yes', 'else is not',
        \  'A->>B: no', 'end', 'A->>B: bye'],
        \ ['sequenceDiagram', '  alt is ok', '    A->>B: yes', '  else is not',
        \  '    A->>B: no', '  end', '  A->>B: bye'])
endfunction

function! Test_activate_deactivate_pair_up() abort
  call AssertIndent('activate',
        \ ['sequenceDiagram', 'activate B', 'B->>A: hi', 'deactivate B'],
        \ ['sequenceDiagram', '  activate B', '    B->>A: hi', '  deactivate B'])
endfunction

function! Test_class_body_braces() abort
  call AssertIndent('class body',
        \ ['classDiagram', 'class Duck {', '+String beakColor', '+swim()', '}'],
        \ ['classDiagram', '  class Duck {', '    +String beakColor',
        \  '    +swim()', '  }'])
endfunction

" A decision node is not a block opener even though it ends in a brace.
function! Test_flowchart_decision_node_is_not_a_block() abort
  call AssertIndent('decision node',
        \ ['graph TD', 'A{Is it?}', 'B --> C'],
        \ ['graph TD', '  A{Is it?}', '  B --> C'])
endfunction

function! Test_diagram_declaration_snaps_back_to_column_zero() abort
  call AssertIndent('declaration at col 0',
        \ ['graph TD', '  A --> B', '    sequenceDiagram'],
        \ ['graph TD', '  A --> B', 'sequenceDiagram'])
endfunction

function! Test_front_matter_is_left_alone() abort
  call AssertIndent('front matter',
        \ ['---', 'title: Demo', '---', 'graph TD', 'A --> B'],
        \ ['---', 'title: Demo', '---', 'graph TD', '  A --> B'])
endfunction

function! Test_comments_follow_the_block_indent() abort
  call AssertIndent('comment inside graph',
        \ ['graph TD', '%% a note', 'A --> B'],
        \ ['graph TD', '  %% a note', '  A --> B'])
endfunction

" Mindmap indentation is the diagram's data; reindenting must not touch it.
function! Test_mindmap_indentation_is_preserved() abort
  let l:lines = ['mindmap', '  root', '    child', '      grandchild']
  call AssertIndent('mindmap', l:lines, l:lines)
endfunction

function! Test_new_line_after_graph_is_indented() abort
  call AssertNextIndent('o after graph', ['graph TD'], 2)
endfunction

function! Test_new_line_in_mindmap_follows_the_line_above() abort
  call AssertNextIndent('o in mindmap', ['mindmap', '  root', '    child'], 4)
endfunction
