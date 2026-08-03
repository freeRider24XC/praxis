#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PUBLIC_DIR="$ROOT_DIR/build/public"
WEB_DIR="$ROOT_DIR/build/web"
DOCS_DIR="$ROOT_DIR/docs"

if [ ! -d "$WEB_DIR" ]; then
  echo "缺少 build/web，请先执行 flutter build web"
  exit 1
fi

rm -rf "$PUBLIC_DIR"
mkdir -p "$PUBLIC_DIR/app"

cp -R "$WEB_DIR"/. "$PUBLIC_DIR/app/"
cp "$DOCS_DIR/download.html" "$PUBLIC_DIR/index.html"
cp "$DOCS_DIR/privacy.html" "$PUBLIC_DIR/privacy.html"
cp "$DOCS_DIR/terms.html" "$PUBLIC_DIR/terms.html"
cp "$DOCS_DIR/version.json" "$PUBLIC_DIR/version.json"

echo "Public site packaged at: $PUBLIC_DIR"
