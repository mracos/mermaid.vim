# mermaid.vim

A vim/neovim plugin providing syntax highlighting, indentation and filetype
support for [mermaid](https://mermaid.js.org/) files (`*.mmd`, `*.mermaid`,
`*.mm`).

![printscreen of the terminal highlighting the mermaid file](./.github/screenshot.png)
using [eva01](https://github.com/hachy/eva01.vim) colorscheme

## Installation

Both `filetype plugin indent on` and `syntax enable` need to be in your vimrc;
the plugin does not set them for you.

### vim-plug

1. Add `Plug 'mracos/mermaid.vim'`
2. Run `:PlugInstall`

### Vundle

1. Add `Plugin 'mracos/mermaid.vim'`
2. Run `:PluginInstall`

### lazy.nvim

```lua
{ 'mracos/mermaid.vim' }
```

### Built-in package manager

```sh
git clone https://github.com/mracos/mermaid.vim \
  ~/.vim/pack/plugins/start/mermaid.vim
```

## What it covers

- Flowchart/graph, sequence, class, state, ER, gantt, pie, journey, gitGraph,
  requirement, quadrant, mindmap, timeline and the `-beta` diagram types
- YAML front matter and `%%{init: ...}%%` directives
- Node shapes and link labels, sequence and class operators, ER cardinality,
  gantt dates and task tags, gitGraph attributes
- Indentation for blocks, with `else`/`and`/`option` kept at the level of the
  branch they belong to, and blank lines no longer resetting the level
- `mindmap`/`timeline`/`packet`/`sankey-beta`, where indentation is the
  diagram's data, are left untouched by `=`

See `:help mermaid` for the details, including `g:mermaid_detect_mm` for the
`*.mm` extension, which vim otherwise maps to objcpp/nroff.

## Tests

No dependencies; the suite runs headlessly against both editors.

```sh
./test/run.sh                    # vim
EDITOR_BIN=nvim ./test/run.sh    # neovim
./test/run.sh indent_spec.vim    # a single spec
```

## Contributing

Please do! Just send a Pull Request and I'll try to see it in due time. :smile:

## License

MIT, see [LICENSE](./LICENSE) for more details.
