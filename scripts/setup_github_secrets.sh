#!/usr/bin/env bash

# Prepare Android signing values for GitHub Actions without storing passwords in git.
set -euo pipefail

KEYSTORE_PATH="${KEYSTORE_PATH:-android/app/keystore.jks}"
REQUIRED_VARS=(
  ANDROID_KEYSTORE_PASSWORD
  ANDROID_KEY_ALIAS
  ANDROID_KEY_PASSWORD
)

if [[ ! -f "$KEYSTORE_PATH" ]]; then
  echo "错误: 找不到密钥库文件: $KEYSTORE_PATH" >&2
  exit 1
fi

for variable in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!variable:-}" ]]; then
    echo "错误: 请先在当前 shell 设置 $variable。脚本不会提供默认口令。" >&2
    exit 1
  fi
done

if base64 --help 2>&1 | grep -q -- "--input"; then
  KEYSTORE_BASE64="$(base64 --input "$KEYSTORE_PATH" | tr -d "\n")"
else
  KEYSTORE_BASE64="$(base64 < "$KEYSTORE_PATH" | tr -d "\n")"
fi

echo "GitHub Actions secrets 已就绪。请使用下列命令写入仓库 secrets："
echo ""
echo "printf '%s' '$KEYSTORE_BASE64' | gh secret set ANDROID_KEYSTORE_BASE64"
echo "printf '%s' '\$ANDROID_KEYSTORE_PASSWORD' | gh secret set ANDROID_KEYSTORE_PASSWORD"
echo "printf '%s' '\$ANDROID_KEY_ALIAS' | gh secret set ANDROID_KEY_ALIAS"
echo "printf '%s' '\$ANDROID_KEY_PASSWORD' | gh secret set ANDROID_KEY_PASSWORD"
echo ""
echo "注意：请在可信终端执行这些命令；不要把命令输出或真实口令提交到仓库。"
