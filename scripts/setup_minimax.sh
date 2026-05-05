#!/bin/bash

# MiniMax API 配置脚本
# 使用方法: ./scripts/setup_minimax.sh <api_key>
#
# 注意: 此脚本会在项目根目录创建本地配置文件，不会提交到版本控制

set -e

API_KEY="$1"

if [ -z "$API_KEY" ]; then
    echo "错误: 请提供 MiniMax API 密钥"
    echo "使用方法: ./scripts/setup_minimax.sh <api_key>"
    echo ""
    echo "示例:"
    echo "  ./scripts/setup_minimax.sh sk-cp-xxxxx"
    exit 1
fi

echo "正在配置 MiniMax API..."

# 创建本地配置目录
mkdir -p local_config

# 创建 API 密钥配置文件
cat > local_config/minimax_api_key.txt << EOF
# MiniMax API 配置
# 此文件不会提交到版本控制
# 创建时间: $(date)
API_KEY=$API_KEY
EOF

echo "✓ MiniMax API 密钥已保存到 local_config/minimax_api_key.txt"
echo ""
echo "配置信息:"
echo "  API 地址: https://api.minimax.chat/v1"
echo "  模型: abab6.5s-chat"
echo ""
echo "提示:"
echo "  - 配置文件已添加到 .gitignore"
echo "  - 不会提交到版本控制系统"
