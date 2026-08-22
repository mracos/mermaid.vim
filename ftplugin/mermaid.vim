" Filetype plugin for mermaid.
" Language:   Mermaid
" URL:        https://github.com/mracos/mermaid.vim

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpoptions
set cpoptions&vim

" Mermaid comments are `%%` and only valid on their own line.
setlocal comments=:%%
setlocal commentstring=%%\ %s

" Diagram types (classDiagram-v2, sankey-beta, ...) and ids (cherry-pick)
" contain dashes, so treat them as part of a word for w/*/# motions.
setlocal iskeyword+=-

setlocal formatoptions-=t formatoptions+=croql

let b:undo_ftplugin = 'setlocal comments< commentstring< iskeyword< formatoptions<'

let &cpoptions = s:cpo_save
unlet s:cpo_save
