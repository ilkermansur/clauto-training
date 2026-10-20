#!/usr/bin/env bash
# Kitabı derler: doc-format/main.pdf
# Kullanım:  ./doc-format/build.sh [ek typst argümanları]
# Gerekenler: typst >= 0.13; Fira Sans, Source Sans 3, JetBrains Mono (sistemde kurulu)
set -euo pipefail
cd "$(dirname "$0")"
# --root ..  → diagrams/ klasörü (slayt projesiyle ortak SVG'ler) okunabilsin
typst compile --root .. --font-path ../fonts "$@" main.typ main.pdf
echo "→ doc-format/main.pdf"
