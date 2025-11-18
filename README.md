# praxis

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 使用工具

- 状态管理：GetX

## 功能分析

- 核心功能：
  - 接入AI工具（deepseek、通义千问、 GPT等等）
  - 通过和AI交流制定目标、项目以及待办
- 待办
- 目标
- 项目
- 统计
- 设置

## 发布流程

本项目使用 GitHub Actions 实现自动化构建和发布。

### 快速发布

使用提供的脚本快速发布新版本：

```bash
./scripts/release.sh 1.0.0
```

脚本会自动：
1. 更新 `pubspec.yaml` 中的版本号
2. 创建并推送版本 tag
3. 触发 GitHub Actions 自动构建

### 手动发布

1. 更新 `pubspec.yaml` 中的版本号
2. 创建并推送 tag：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

### 构建产物

构建完成后，可以在以下位置获取构建产物：

- **GitHub Releases**: 访问仓库的 Releases 页面
- **下载页面**: 访问 `docs/download.html`，会自动显示最新版本的下载链接

### 配置说明

详细的配置说明请查看 [发布配置指南](docs/RELEASE_SETUP.md)。

### 版本号格式

遵循语义化版本（Semantic Versioning）：
- 格式：`主版本号.次版本号.修订号`
- 示例：`1.0.0`, `1.2.3`, `2.0.0-beta.1`