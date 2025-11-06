#!/bin/bash

# 版本管理脚本
# 用法: ./scripts/version.sh [major|minor|patch] [message]

set -e

VERSION_TYPE=${1:-patch}
COMMIT_MESSAGE=${2:-"版本更新"}

# 读取当前版本
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
VERSION_PARTS=($(echo $CURRENT_VERSION | tr '.' ' '))
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# 计算新版本
case $VERSION_TYPE in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "错误: 版本类型必须是 major, minor 或 patch"
    exit 1
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
BUILD_NUMBER=$(date +%s)

echo "当前版本: $CURRENT_VERSION"
echo "新版本: $NEW_VERSION+$BUILD_NUMBER"

# 更新 pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s/^version: .*/version: $NEW_VERSION+$BUILD_NUMBER/" pubspec.yaml
else
  # Linux
  sed -i "s/^version: .*/version: $NEW_VERSION+$BUILD_NUMBER/" pubspec.yaml
fi

# 创建 Git 标签
git add pubspec.yaml
git commit -m "$COMMIT_MESSAGE - v$NEW_VERSION"
git tag -a "v$NEW_VERSION" -m "$COMMIT_MESSAGE"

echo "✅ 版本已更新到 $NEW_VERSION+$BUILD_NUMBER"
echo "✅ Git 标签已创建: v$NEW_VERSION"
echo ""
echo "运行以下命令推送标签:"
echo "  git push && git push --tags"

