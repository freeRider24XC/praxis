#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_DIR="$ROOT_DIR/server/managed-ai"

cd "$SERVER_DIR"

if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

node src/index.js
