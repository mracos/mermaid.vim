" Vim syntax file
" Language:   Mermaid
" URL:        https://github.com/mracos/mermaid.vim
"
" Every rule carries an example of what it matches, above it.
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

" A --> B          the bare punctuation, for anything not claimed below
syntax match mermaidOperator /\v(-|\<|\>|\+|\||\=)/

" pie: "Dogs" : 42        xychart: bar [10, 20.5]
syntax match mermaidNumber /\v<\d+(\.\d+)?>/

" %%{init: {"htmlLabels": true} }%%
syntax keyword mermaidBoolean true false

" gantt: task :done, 2024-01-31, 3d
syntax match mermaidDate /\v<\d{4}-\d{2}-\d{2}>/

" classDiagram: <<interface>>       stateDiagram: <<fork>>
syntax match mermaidSpecialAnnotation /\v\<\<\w+\>\>/

" ------------------------------------------------------------ diagram types

" flowchart LR   /   classDiagram-v2   /   gitGraph   /   xychart-beta
"
" Taken from the detector regexes in mermaid's source, not the docs page. Note
" that several types dropped their `-beta` suffix but still accept it, so both
" spellings are listed. Longest alternative first: `treemap-beta` has to be
" tried before `treemap`, otherwise `>` ends the match at the dash.
"
" Bare `requirement` is a valid opener but is left out: inside a
" requirementDiagram `requirement r1 {` is far more common, and mermaidKeyword
" claims it either way.
syntax match mermaidDiagramType
      \ /\v^\s*(agentflow-beta|architecture-beta|architecture|block-beta|block|C4Context|C4Container|C4Component|C4Dynamic|C4Deployment|classDiagram-v2|classDiagram|cynefin-beta|erDiagram|eventmodeling|flowchart-elk|flowchart|gantt|gitGraph|graph|info|ishikawa-beta|ishikawa|journey|kanban|mindmap|packet-beta|packet|pie|quadrantChart|radar-beta|railroad-abnf-beta|railroad-ebnf-beta|railroad-peg-beta|railroad-beta|requirementDiagram|sankey-beta|sankey|sequenceDiagram|stateDiagram-v2|stateDiagram|swimlane-beta|timeline|treemap-beta|treemap|treeView-beta|usecase-beta|venn-beta|wardley-beta|xychart-beta|xychart|zenuml)>/
      \ nextgroup=mermaidDirection skipwhite

" flowchart LR          the `LR` part only
syntax match mermaidDirection /\v(TB|TD|BT|RL|LR)>/ contained

" subgraph one   /   loop every minute   /   participant Alice   /   end
syntax match mermaidKeyword
      \ /\v^\s*(subgraph|loop|alt|else|opt|par|and|rect|critical|option|break|box|end|participant|actor|activate|deactivate|autonumber|create|destroy|namespace|direction|section|state|requirement|element|columns|space)>/

" participant A as Alice      state "long name" as s1
syntax match mermaidKeyword /\v<as>/

" title Order flow   /   accTitle: Order flow   /   accDescr: ...
syntax match mermaidTitle /\v^\s*(title|accTitle|accDescr)>/

" ---------------------------------------------------------------- flowchart

" A --> B   /   A ==> B   /   A -.-> B   /   A --o B   /   A x--x B
syntax match mermaidGraphOperator /\v[ox<]?(--+|\=\=+|-\.+-+|\.-|-\.)[.=-]*[>ox|]?/

" A & B --> C
syntax match mermaidGraphOperator /\v\&/

" click A "https://x" _blank   /   classDef hot fill:#f00   /   style A fill:#f9f
syntax match mermaidGraphClickKeyword
      \ /\v^\s*(click|href|call|callback|style|classDef|linkStyle|class|cssClass|default)>/

" ----------------------------------------------------------------- sequence

" note right of Alice: thinking
syntax match mermaidNote /\v^\s*(note|Note)>/ nextgroup=mermaidNoteDirection skipwhite

" note right of Alice: thinking       the `right of` part only
syntax match mermaidNoteDirection /\v(left of|right of|over)>/ contained

" rect rgb(0, 255, 0)
syntax keyword mermaidSequenceFunction rgb

" -------------------------------------------------------------------- class

" class Duck
syntax keyword mermaidClassClassKeyword class

" +String beakColor      erDiagram: string name PK
syntax keyword mermaidClassType
      \ int integer bool boolean string float double long short byte char
      \ bigdecimal decimal symbol void any date datetime List Map Set Array

" -List~int~ ids   /   class Box~T~
syntax match mermaidClassGenericType /\v\w+\~[^~]+\~/

" Animal <|-- Duck   /   Duck ..|> Flyer   /   Order *-- LineItem
syntax match mermaidClassOperator
      \ /\v(\*--|--\*|o--|--o|\<\|--|--\|\>|\<\.\.|\.\.\>|\|\.\.|\.\.\|)/

" class Duck {
"   +swim() bool
" }
"
" Method syntax only means something inside a class body. Scoping it here is
" what keeps `SecondStep(Go Shopping)` in a flowchart from reading as a method.
" The lookbehind keeps the region start on the `{` alone; `\zs` is silently
" ignored in a region start pattern.
syntax region mermaidClassBody
      \ start=/\v(^\s*(class|namespace)\s+[^{]*)@<=\{/ end=/\v^\s*\}/ keepend
      \ contains=mermaidClassVisibility,mermaidClassType,mermaidClassGenericType,mermaidClassFunction,mermaidSpecialAnnotation,mermaidString,mermaidComment

" +swim()   /   -id   /   #protectedField   /   ~packageInternal
syntax match mermaidClassVisibility /\v^\s*\zs[+\-#~]/ contained

" +setName(String name)
syntax match mermaidClassFunction /\v\w+\([^()]*\)/ contained
      \ contains=mermaidClassType,mermaidClassGenericType

" -------------------------------------------------------------------- state

" [*] --> Still   /   Still --> [*]
syntax match mermaidStateFinalKeyword /\[\*\]/

" state fork_state <<fork>>
syntax match mermaidStateKeyword /\v^\s*state>/

" hide empty description
syntax match mermaidStateKeyword /\v^\s*hide empty description>/

" ----------------------------------------------------------------------- er

" CUSTOMER ||--o{ ORDER : places   /   ORDER }|..|{ LINE-ITEM : contains
"
" Defined after the generic and flowchart operators so it wins on the leading
" `|`, which those would otherwise claim first.
syntax match mermaidErOperator /\v[|}][o|]\s*(--|\.\.)\s*[o|][|{]/

" string name PK   /   int customerId FK
syntax keyword mermaidErAttributeKey PK FK UK

" -------------------------------------------------------------------- gantt

" dateFormat YYYY-MM-DD   /   axisFormat %m/%d   /   excludes weekends
syntax match mermaidGanttKeyword
      \ /\v^\s*(dateFormat|axisFormat|tickInterval|todayMarker|excludes|includes|inclusiveEndDates|topAxis|weekday)>/

" Write docs :crit, done, 2024-01-31, 3d      the `crit`/`done` part only
syntax match mermaidGanttTaskTag /\v(:|,)\s*\zs(done|active|crit|milestone|vert|after)>/

" ----------------------------------------------------------------- gitGraph

" options
"
" `end` is deliberately not listed here; it belongs to mermaidKeyword, which
" would otherwise lose it to this rule in every other diagram type.
syntax match mermaidGitOption /\v^\s*options>/

" commit   /   branch develop   /   merge main   /   cherry-pick id: "abc"
syntax match mermaidGitCommands
      \ /\v^\s*(commit|branch|merge|reset|checkout|cherry-pick)>/

" commit id: "one" tag: "v1.0"       the `id:`/`tag:` part only
syntax match mermaidGitAttribute /\v<(id|tag|type|order|parent)\ze\s*:/

" commit type: HIGHLIGHT
syntax keyword mermaidGitCommitType NORMAL REVERSE HIGHLIGHT

" -------------------------------------------------------- requirement / misc

" functionalRequirement r1 {   /   designConstraint c2 {
syntax match mermaidRequirementKeyword
      \ /\v^\s*(functionalRequirement|interfaceRequirement|performanceRequirement|physicalRequirement|designConstraint)>/

" id: 1   /   risk: High   /   verifymethod: Test   /   docref: spec.pdf
syntax match mermaidRequirementAttribute
      \ /\v^\s*(id|text|risk|verifymethod|type|docref)\ze\s*:/

" risk: High   /   verifymethod: Analysis
syntax keyword mermaidRequirementValue
      \ Low Medium High Analysis Inspection Test Demonstration

" r1 - satisfies -> e1
"
" Anchored to the `- ... ->` position so that an erDiagram label such as
" `ORDER }|..|{ LINE : contains` is left alone. `contains` is also a reserved
" argument of :syntax keyword, which is why this cannot be one.
syntax match mermaidRequirementRelation
      \ /\v(-\s*)@<=(satisfies|contains|copies|derives|refines|traces|verifies)(\s*-\>)@=/

" x-axis Low --> High   /   quadrant-1 Do it now
syntax match mermaidQuadrantKeyword /\v^\s*(x-axis|y-axis|quadrant-[1-4])>/

" mindmap: Origins ::icon(fa fa-book)
syntax match mermaidMindmapIcon /\v::icon\([^)]*\)/

" ------------------------------------------------------------------- labels

" A -->|yes| B      the `|yes|` part only
syntax match mermaidGraphLinkText /\v\|[^|]+\|/ contains=mermaidString

" A[Square]   /   B(Round)   /   C((Circle))   /   D{{Hexagon}}   /   E[/Para/]
"
" The lookahead keeps `[*]` for the stateDiagram start/end marker out of this.
syntax region mermaidNodeLabel matchgroup=mermaidNodeDelim
      \ start=/\v([[({]{1,3}[\\\/]?)(\*\])@!/ end=/\v[\\\/]?[])}]{1,3}/ oneline keepend
      \ contains=mermaidString,mermaidNumber,@Spell

" -------------------------------------------------------------- structural

" commit id: "one"   /   state "long description" as s1
syntax region mermaidString start=/"/ skip=/\\"/ end=/"/ oneline contains=@Spell

" %%{init: {"theme": "dark", "flowchart": {"curve": "linear"}} }%%
syntax region mermaidDirective matchgroup=mermaidDirectiveDelim
      \ start=/%%{/ end=/}%%/ keepend
      \ contains=mermaidString,mermaidNumber,mermaidBoolean

" ---
" title: Order flow
" ---
"
" Only valid as the very first line of the file, hence `\%^`.
syntax region mermaidFrontMatter matchgroup=mermaidFrontMatterDelim
      \ start=/\%^---$/ end=/^---$/ keepend
      \ contains=mermaidFrontMatterKey,mermaidString,mermaidNumber

" title: Order flow      the `title` part only, inside front matter
syntax match mermaidFrontMatterKey /^\s*[[:alnum:]_-]\+\ze\s*:/ contained

" %% this is a comment
"
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
