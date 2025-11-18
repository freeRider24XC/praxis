#!/bin/bash

# 设置 GitHub Secrets 的辅助脚本
# 此脚本会生成 base64 编码的密钥库和证书，方便复制到 GitHub Secrets

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== GitHub Secrets 配置助手 ===${NC}\n"

# 检查密钥库是否存在
KEYSTORE_PATH="android/app/keystore.jks"
if [ ! -f "$KEYSTORE_PATH" ]; then
    echo -e "${RED}错误: 找不到密钥库文件 $KEYSTORE_PATH${NC}"
    echo "请先运行密钥库生成命令或确保文件存在"
    exit 1
fi

echo -e "${GREEN}1. Android 密钥库配置${NC}"
echo "----------------------------------------"
echo -e "${YELLOW}密钥库路径:${NC} $KEYSTORE_PATH"
echo ""
echo -e "${YELLOW}请将以下内容添加到 GitHub Secrets:${NC}"
echo ""
echo -e "${BLUE}ANDROID_KEYSTORE_BASE64:${NC}"
KEYSTORE_BASE64=$(base64 -i "$KEYSTORE_PATH")
if command -v pbcopy &> /dev/null; then
    echo "$KEYSTORE_BASE64" | pbcopy
    echo -e "${GREEN}(已复制到剪贴板)${NC}"
    echo "$KEYSTORE_BASE64"
else
    echo "$KEYSTORE_BASE64"
fi
echo ""
echo -e "${BLUE}ANDROID_KEYSTORE_PASSWORD:${NC} praxis123"
echo ""
echo -e "${BLUE}ANDROID_KEY_ALIAS:${NC} praxis"
echo ""
echo -e "${BLUE}ANDROID_KEY_PASSWORD:${NC} praxis123"
echo ""
echo -e "${GREEN}=== 配置步骤 ===${NC}"
echo "1. 访问您的 GitHub 仓库"
echo "2. 进入 Settings > Secrets and variables > Actions"
echo "3. 点击 'New repository secret'"
echo "4. 添加上述各个 Secret"
echo ""
echo -e "${YELLOW}注意:${NC} 密钥库密码和密钥密码当前为默认值 'praxis123'"
echo "建议在生产环境中使用更安全的密码"

