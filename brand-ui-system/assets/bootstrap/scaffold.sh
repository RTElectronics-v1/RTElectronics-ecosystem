#!/usr/bin/env bash
# scaffold.sh — copies the brand-ui-system starter into a target directory.
# Usage: bash scaffold.sh <target-dir>
set -euo pipefail

DEST="${1:?usage: scaffold.sh <target-dir>}"
SRC="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$DEST/src/styles" "$DEST/src/layouts" "$DEST/src/scripts" "$DEST/src/pages"

cp "$SRC/global.css" "$DEST/src/styles/global.css"
cp "$SRC/Base.astro" "$DEST/src/layouts/Base.astro"
cp "$SRC/reveal.ts" "$DEST/src/scripts/reveal.ts"
cp "$SRC/index.astro" "$DEST/src/pages/index.astro"
cp "$SRC/package.json" "$SRC/astro.config.mjs" "$SRC/tsconfig.json" "$DEST/"

echo "brand-ui-system: scaffolded into $DEST"
echo "next: cd \"$DEST\" && npm install && npm run verify"
