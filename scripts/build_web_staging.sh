#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${1:-$ROOT_DIR/deploy/staging/.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "缺少环境文件: $ENV_FILE"
  echo "请先复制 deploy/staging/.env.example 到 deploy/staging/.env"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

cd "$ROOT_DIR"

PUBLIC_BASE_PATH="${PRAXIS_PUBLIC_BASE_PATH:-/}"
case "$PUBLIC_BASE_PATH" in
  /*) ;;
  *) PUBLIC_BASE_PATH="/$PUBLIC_BASE_PATH" ;;
esac

if [ "$PUBLIC_BASE_PATH" != "/" ]; then
  PUBLIC_BASE_PATH="${PUBLIC_BASE_PATH%/}"
fi

FLUTTER_BASE_HREF="${PUBLIC_BASE_PATH}/app/"

fvm flutter build web \
  --base-href "$FLUTTER_BASE_HREF" \
  --dart-define=PRAXIS_STAGE="${PRAXIS_STAGE:-staging}" \
  --dart-define=PRAXIS_SUPABASE_URL="${PRAXIS_SUPABASE_URL:-}" \
  --dart-define=PRAXIS_SUPABASE_ANON_KEY="${PRAXIS_SUPABASE_ANON_KEY:-}" \
  --dart-define=PRAXIS_AI_API_BASE_URL="${PRAXIS_AI_API_BASE_URL:-}" \
  --dart-define=PRAXIS_AI_API_TOKEN="${PRAXIS_AI_API_TOKEN:-}" \
  --dart-define=PRAXIS_REQUIRE_CLOUD_AUTH=true
