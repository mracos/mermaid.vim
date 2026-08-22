#!/usr/bin/env bash
# Run the plugin's test suite headlessly.
#
#   test/run.sh              # vim, all specs
#   EDITOR_BIN=nvim test/run.sh
#   test/run.sh indent_spec.vim

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bin="${EDITOR_BIN:-vim}"
specs="$(IFS=,; echo "$*")"

if ! command -v "$bin" >/dev/null 2>&1; then
  echo "$bin not found" >&2
  exit 127
fi

if [ "$("$bin" --version | head -1 | cut -c1-4)" = "NVIM" ]; then
  headless=(--headless)
else
  headless=(-N -es)
fi

"$bin" "${headless[@]}" -u "$root/test/vimrc" \
  --cmd "let g:mermaid_test_specs = '$specs'" \
  -S "$root/test/run.vim" 2>&1 | tr -d '\r'
