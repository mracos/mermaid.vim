" Syntax highlighting.

function! Test_diagram_types_are_constants() abort
  call AssertSyntax('graph', ['graph TD'], 1, 'graph', 'mermaidDiagramType')
  call AssertSyntax('classDiagram-v2', ['classDiagram-v2'], 1,
        \ 'classDiagram-v2', 'mermaidDiagramType')
  call AssertSyntax('mindmap', ['mindmap'], 1, 'mindmap', 'mermaidDiagramType')
  call AssertSyntax('gitGraph', ['gitGraph'], 1, 'gitGraph', 'mermaidDiagramType')
  call AssertSyntax('quadrantChart', ['quadrantChart'], 1,
        \ 'quadrantChart', 'mermaidDiagramType')
endfunction

" The `-beta` suffix was dropped upstream for several types but is still
" accepted, so both spellings have to highlight.
function! Test_diagram_types_with_and_without_the_beta_suffix() abort
  for l:name in ['sankey', 'sankey-beta', 'xychart', 'xychart-beta',
        \ 'block', 'block-beta', 'packet', 'packet-beta', 'treemap',
        \ 'treemap-beta', 'architecture', 'architecture-beta',
        \ 'ishikawa', 'ishikawa-beta', 'requirementDiagram']
    call AssertSyntax(l:name, [l:name], 1, '\V' . l:name . '\$',
          \ 'mermaidDiagramType')
  endfor
endfunction

" Types added to mermaid after this plugin was first written.
function! Test_recent_diagram_types() abort
  for l:name in ['agentflow-beta', 'cynefin-beta', 'eventmodeling', 'kanban',
        \ 'radar-beta', 'railroad-beta', 'railroad-abnf-beta',
        \ 'railroad-ebnf-beta', 'railroad-peg-beta', 'swimlane-beta',
        \ 'treeView-beta', 'usecase-beta', 'venn-beta', 'wardley-beta']
    call AssertSyntax(l:name, [l:name], 1, '\V' . l:name . '\$',
          \ 'mermaidDiagramType')
  endfor
endfunction

function! Test_direction_after_a_declaration() abort
  call AssertSyntax('direction', ['flowchart LR'], 1, 'LR', 'mermaidDirection')
endfunction

function! Test_comments() abort
  call AssertSyntax('comment', ['graph TD', '  %% hello'], 2, '%%', 'mermaidComment')
endfunction

" Regression: `%%{init: ...}%%` is a directive, not a comment.
function! Test_directives_are_not_comments() abort
  call AssertSyntax('directive', ['%%{init: {"theme": "dark"} }%%'], 1,
        \ 'init', 'mermaidDirective')
endfunction

function! Test_front_matter() abort
  call AssertSyntax('front matter key', ['---', 'title: Demo', '---', 'graph TD'],
        \ 2, 'title', 'mermaidFrontMatterKey')
endfunction

function! Test_strings() abort
  call AssertSyntax('string', ['gitGraph', '  commit id: "one"'], 2, '"', 'mermaidString')
endfunction

function! Test_block_keywords() abort
  call AssertSyntax('subgraph', ['graph TD', '  subgraph one'], 2,
        \ 'subgraph', 'mermaidKeyword')
  call AssertSyntax('end', ['graph TD', '  end'], 2, 'end', 'mermaidKeyword')
endfunction

" Regression: block keywords at column 0 are legal mermaid and used to be missed.
function! Test_block_keyword_at_column_zero() abort
  call AssertSyntax('subgraph col 0', ['graph TD', 'subgraph one'], 2,
        \ 'subgraph', 'mermaidKeyword')
endfunction

function! Test_git_commands_and_attributes() abort
  call AssertSyntax('cherry-pick', ['gitGraph', '  cherry-pick id: "a"'], 2,
        \ 'cherry-pick', 'mermaidGitCommands')
  call AssertSyntax('commit type', ['gitGraph', '  commit type: HIGHLIGHT'], 2,
        \ 'HIGHLIGHT', 'mermaidGitCommitType')
endfunction

function! Test_gantt_keywords() abort
  call AssertSyntax('dateFormat', ['gantt', '  dateFormat YYYY-MM-DD'], 2,
        \ 'dateFormat', 'mermaidGanttKeyword')
  call AssertSyntax('date', ['gantt', '  a task :done, 2024-01-01, 3d'], 2,
        \ '2024-01-01', 'mermaidDate')
  call AssertSyntax('task tag', ['gantt', '  a task :done, 2024-01-01, 3d'], 2,
        \ 'done', 'mermaidGanttTaskTag')
endfunction

function! Test_er_cardinality() abort
  call AssertSyntax('er operator', ['erDiagram', '  CUSTOMER ||--o{ ORDER : places'],
        \ 2, '||--o{', 'mermaidErOperator')
endfunction

function! Test_class_annotations_and_generics() abort
  call AssertSyntax('annotation', ['classDiagram', '  <<interface>> Shape'], 2,
        \ '<<interface>>', 'mermaidSpecialAnnotation')
  call AssertSyntax('generic', ['classDiagram', '  class Box~T~'], 2,
        \ 'Box\~T\~', 'mermaidClassGenericType')
endfunction

" Regression: `SecondStep(Go Shopping)` was highlighted as a class method.
function! Test_flowchart_node_label_is_not_a_class_method() abort
  call AssertSyntax('node label', ['graph TD', '  A --> SecondStep(Go Shopping)'],
        \ 2, 'Go Shopping', 'mermaidNodeLabel')
endfunction

function! Test_class_method_inside_a_class_body() abort
  call AssertSyntax('class method',
        \ ['classDiagram', '  class Duck {', '    +swim()', '  }'],
        \ 3, 'swim(', 'mermaidClassFunction')
endfunction

function! Test_state_final_marker() abort
  call AssertSyntax('final state', ['stateDiagram-v2', '  [*] --> Still'], 2,
        \ '\[\*\]', 'mermaidStateFinalKeyword')
endfunction

function! Test_sequence_note_direction() abort
  call AssertSyntax('note', ['sequenceDiagram', '  note right of A: hi'], 2,
        \ 'note', 'mermaidNote')
  call AssertSyntax('note direction', ['sequenceDiagram', '  note right of A: hi'],
        \ 2, 'right of', 'mermaidNoteDirection')
endfunction

" `highlight link` (no `default`) clobbered colorschemes loaded afterwards.
function! Test_highlight_links_are_overridable() abort
  call Setup(['graph TD'])
  highlight link mermaidComment Error
  syntax enable
  call assert_equal('Error',
        \ synIDattr(synIDtrans(hlID('mermaidComment')), 'name'),
        \ 'user highlight link survives')
  highlight link mermaidComment Comment
endfunction
