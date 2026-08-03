#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY_DIR="$ROOT_DIR/deploy/staging"

cd "$ROOT_DIR"
bash scripts/build_web_staging.sh "$DEPLOY_DIR/.env"
bash scripts/package_public_site.sh

cd "$DEPLOY_DIR"
docker compose up -d --build
