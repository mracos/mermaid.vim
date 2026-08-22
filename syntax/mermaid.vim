" Vim syntax file
" Language:   Mermaid
" URL:        https://github.com/mracos/mermaid.vim
"
" Ordering matters: when two items match at the same position the one defined
" last wins, so the structural items (strings, directives, front matter,
" comments) are defined at the bottom.

if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpoptions
set cpoptions&vim

syntax case match
syntax sync minlines=50

" ------------------------------------------------------------------ generic

syntax match mermaidOperator /\v(-|\<|\>|\+|\||\=)/
syntax match mermaidNumber /\v<\d+(\.\d+)?>/
syntax keyword mermaidBoolean true false
syntax match mermaidDate /\v<\d{4}-\d{2}-\d{2}>/
syntax match mermaidSpecialAnnotation /\v\<\<\w+\>\>/

" ------------------------------------------------------------ diagram types

" Longest alternative first: classDiagram-v2 must win over classDiagram.
syntax match mermaidDiagramType
      \ /\v^\s*(architecture-beta|block-beta|C4Context|C4Container|C4Component|C4Dynamic|C4Deployment|classDiagram-v2|classDiagram|erDiagram|flowchart-elk|flowchart|gantt|gitGraph|graph|info|journey|kanban|mindmap|packet-beta|packet|pie|quadrantChart|radar-beta|requirementDiagram|sankey-beta|sequenceDiagram|stateDiagram-v2|stateDiagram|timeline|treemap-beta|usecase-beta|xychart-beta|zenuml)>/
      \ nextgroup=mermaidDirection skipwhite

syntax match mermaidDirection /\v(TB|TD|BT|RL|LR)>/ contained

" Shared across every diagram type.
syntax match mermaidKeyword
      \ /\v^\s*(subgraph|loop|alt|else|opt|par|and|rect|critical|option|break|box|end|participant|actor|activate|deactivate|autonumber|create|destroy|namespace|direction|section|state|requirement|element|columns|space)>/
syntax match mermaidKeyword /\v<as>/
syntax match mermaidTitle /\v^\s*(title|accTitle|accDescr)>/

" ---------------------------------------------------------------- flowchart

syntax match mermaidGraphOperator /\v[ox<]?(--+|\=\=+|-\.+-+|\.-|-\.)[.=-]*[>ox|]?/
syntax match mermaidGraphOperator /\v\&/
syntax match mermaidGraphClickKeyword
      \ /\v^\s*(click|href|call|callback|style|classDef|linkStyle|class|cssClass|default)>/

" ----------------------------------------------------------------- sequence

syntax match mermaidNote /\v^\s*(note|Note)>/ nextgroup=mermaidNoteDirection skipwhite
syntax match mermaidNoteDirection /\v(left of|right of|over)>/ contained
syntax keyword mermaidSequenceFunction rgb

" -------------------------------------------------------------------- class

syntax keyword mermaidClassClassKeyword class
syntax keyword mermaidClassType
      \ int integer bool boolean string float double long short byte char
      \ bigdecimal decimal symbol void any date datetime List Map Set Array
syntax match mermaidClassGenericType /\v\w+\~[^~]+\~/
syntax match mermaidClassOperator
      \ /\v(\*--|--\*|o--|--o|\<\|--|--\|\>|\<\.\.|\.\.\>|\|\.\.|\.\.\|)/

" Method syntax only means something inside a class body. Scoping it here is
" what keeps `SecondStep(Go Shopping)` in a flowchart from reading as a method.
" The lookbehind keeps the region start on the `{` alone; `\zs` is silently
" ignored in a region start pattern.
syntax region mermaidClassBody
      \ start=/\v(^\s*(class|namespace)\s+[^{]*)@<=\{/ end=/\v^\s*\}/ keepend
      \ contains=mermaidClassVisibility,mermaidClassType,mermaidClassGenericType,mermaidClassFunction,mermaidSpecialAnnotation,mermaidString,mermaidComment
syntax match mermaidClassVisibility /\v^\s*\zs[+\-#~]/ contained
syntax match mermaidClassFunction /\v\w+\([^()]*\)/ contained
      \ contains=mermaidClassType,mermaidClassGenericType

" -------------------------------------------------------------------- state

syntax match mermaidStateFinalKeyword /\[\*\]/
syntax match mermaidStateKeyword /\v^\s*state>/
syntax match mermaidStateKeyword /\v^\s*hide empty description>/

" ----------------------------------------------------------------------- er

" Cardinality pairs: ||--o{, }o..o|, and friends. Defined after the generic
" and flowchart operators so it wins on the leading `|`.
syntax match mermaidErOperator /\v[|}][o|]\s*(--|\.\.)\s*[o|][|{]/
syntax keyword mermaidErAttributeKey PK FK UK

" -------------------------------------------------------------------- gantt

syntax match mermaidGanttKeyword
      \ /\v^\s*(dateFormat|axisFormat|tickInterval|todayMarker|excludes|includes|inclusiveEndDates|topAxis|weekday)>/
syntax match mermaidGanttTaskTag /\v(:|,)\s*\zs(done|active|crit|milestone|vert|after)>/

" ----------------------------------------------------------------- gitGraph

" `end` is deliberately not listed here; it belongs to mermaidKeyword.
syntax match mermaidGitOption /\v^\s*options>/
syntax match mermaidGitCommands
      \ /\v^\s*(commit|branch|merge|reset|checkout|cherry-pick)>/
syntax match mermaidGitAttribute /\v<(id|tag|type|order|parent)\ze\s*:/
syntax keyword mermaidGitCommitType NORMAL REVERSE HIGHLIGHT

" -------------------------------------------------------- requirement / misc

syntax match mermaidRequirementKeyword
      \ /\v^\s*(functionalRequirement|interfaceRequirement|performanceRequirement|physicalRequirement|designConstraint)>/
syntax match mermaidRequirementAttribute
      \ /\v^\s*(id|text|risk|verifymethod|type|docref)\ze\s*:/
syntax keyword mermaidRequirementValue
      \ Low Medium High Analysis Inspection Test Demonstration
" `contains` is a reserved argument of :syntax keyword, so this has to be a match.
syntax match mermaidRequirementRelation
      \ /\v(-\s*)@<=(satisfies|contains|copies|derives|refines|traces|verifies)(\s*-\>)@=/

syntax match mermaidQuadrantKeyword /\v^\s*(x-axis|y-axis|quadrant-[1-4])>/
syntax match mermaidMindmapIcon /\v::icon\([^)]*\)/

" ----------------------------------------------------------------- labels

syntax match mermaidGraphLinkText /\v\|[^|]+\|/ contains=mermaidString
syntax region mermaidNodeLabel matchgroup=mermaidNodeDelim
      \ start=/\v([[({]{1,3}[\\\/]?)(\*\])@!/ end=/\v[\\\/]?[])}]{1,3}/ oneline keepend
      \ contains=mermaidString,mermaidNumber,@Spell

" -------------------------------------------------------------- structural

syntax region mermaidString start=/"/ skip=/\\"/ end=/"/ oneline contains=@Spell

" `%%{init: {"theme": "dark"} }%%` directives.
syntax region mermaidDirective matchgroup=mermaidDirectiveDelim
      \ start=/%%{/ end=/}%%/ keepend
      \ contains=mermaidString,mermaidNumber,mermaidBoolean

" YAML front matter, only valid as the very first line of the file.
syntax region mermaidFrontMatter matchgroup=mermaidFrontMatterDelim
      \ start=/\%^---$/ end=/^---$/ keepend
      \ contains=mermaidFrontMatterKey,mermaidString,mermaidNumber
syntax match mermaidFrontMatterKey /^\s*[[:alnum:]_-]\+\ze\s*:/ contained

" Comments are whole-line only in mermaid; `%%{` is a directive, not a comment.
syntax match mermaidComment /^\s*%%\%({\)\@!.*$/ contains=@Spell

" --------------------------------------------------------------- highlights
" `default` so a colorscheme sourced after the syntax file still wins.

highlight default link mermaidDiagramType Constant
highlight default link mermaidDirection Constant
highlight default link mermaidOperator Operator
highlight default link mermaidComment Comment
highlight default link mermaidString String
highlight default link mermaidNumber Number
highlight default link mermaidBoolean Boolean
highlight default link mermaidDate Constant
highlight default link mermaidSpecialAnnotation Label
highlight default link mermaidNote Keyword
highlight default link mermaidNoteDirection Keyword
highlight default link mermaidKeyword Keyword
highlight default link mermaidTitle Title

highlight default link mermaidFrontMatterDelim Delimiter
highlight default link mermaidFrontMatterKey Identifier
highlight default link mermaidDirective PreProc
highlight default link mermaidDirectiveDelim PreProc

highlight default link mermaidGraphOperator Operator
highlight default link mermaidGraphClickKeyword Keyword
highlight default link mermaidGraphLinkText String
highlight default link mermaidNodeLabel String
highlight default link mermaidNodeDelim Delimiter

highlight default link mermaidSequenceFunction Function

highlight default link mermaidClassClassKeyword Keyword
highlight default link mermaidClassOperator Operator
highlight default link mermaidClassType Type
highlight default link mermaidClassGenericType Type
highlight default link mermaidClassFunction Function
highlight default link mermaidClassVisibility Special

highlight default link mermaidStateFinalKeyword Keyword
highlight default link mermaidStateKeyword Keyword

highlight default link mermaidErOperator Operator
highlight default link mermaidErAttributeKey Special

highlight default link mermaidGanttKeyword Keyword
highlight default link mermaidGanttTaskTag Special

highlight default link mermaidGitOption Keyword
highlight default link mermaidGitCommands Keyword
highlight default link mermaidGitAttribute Identifier
highlight default link mermaidGitCommitType Constant

highlight default link mermaidRequirementKeyword Keyword
highlight default link mermaidRequirementAttribute Identifier
highlight default link mermaidRequirementValue Constant
highlight default link mermaidRequirementRelation Keyword

highlight default link mermaidQuadrantKeyword Keyword
highlight default link mermaidMindmapIcon Special

let b:current_syntax = 'mermaid'

let &cpoptions = s:cpo_save
unlet s:cpo_save
