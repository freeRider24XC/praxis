#!/bin/bash

# 发布脚本
# 用法: ./scripts/release.sh [版本号]
# 示例: ./scripts/release.sh 1.0.0

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查参数
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供版本号${NC}"
    echo "用法: $0 [版本号]"
    echo "示例: $0 1.0.0"
    exit 1
fi

VERSION=$1
TAG="v${VERSION}"

# 验证版本号格式（简单验证）
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
    echo -e "${YELLOW}警告: 版本号格式可能不正确，建议使用语义化版本 (如: 1.0.0)${NC}"
    read -p "是否继续? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}警告: 检测到未提交的更改${NC}"
    git status --short
    read -p "是否继续? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查 tag 是否已存在
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo -e "${RED}错误: Tag $TAG 已存在${NC}"
    exit 1
fi

# 更新 pubspec.yaml 中的版本号
echo -e "${GREEN}更新 pubspec.yaml 中的版本号...${NC}"
BUILD_NUMBER=$(echo $VERSION | cut -d'.' -f1)
sed -i.bak "s/^version:.*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml
rm pubspec.yaml.bak 2>/dev/null || true

# 显示更改
echo -e "${GREEN}版本号已更新:${NC}"
grep "^version:" pubspec.yaml

# 确认
read -p "确认创建 tag $TAG 并推送到远程? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}已取消${NC}"
    git checkout pubspec.yaml 2>/dev/null || true
    exit 1
fi

# 提交版本号更改
echo -e "${GREEN}提交版本号更改...${NC}"
git add pubspec.yaml
git commit -m "chore: bump version to $VERSION" || true

# 创建 tag
echo -e "${GREEN}创建 tag $TAG...${NC}"
git tag -a "$TAG" -m "Release $VERSION"

# 推送到远程
echo -e "${GREEN}推送到远程仓库...${NC}"
git push origin HEAD
git push origin "$TAG"

echo -e "${GREEN}✓ 发布流程已启动！${NC}"
echo -e "${GREEN}GitHub Actions 将自动构建并发布版本 $VERSION${NC}"
echo -e "${YELLOW}查看构建进度: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions${NC}"

