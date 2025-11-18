# Android 打包测试指南

本指南帮助您测试 Android 自动打包功能是否正常工作。

## 前置条件

### 1. 配置 GitHub Secrets

在测试之前，确保已在 GitHub 仓库中配置了 Android 签名相关的 Secrets：

1. **运行配置脚本获取 base64 编码**:
   ```bash
   ./scripts/setup_github_secrets.sh
   ```

2. **在 GitHub 仓库中添加 Secrets**:
   - 访问：`Settings > Secrets and variables > Actions`
   - 添加以下 4 个 Secrets：
     - `ANDROID_KEYSTORE_BASE64`: 从脚本输出复制
     - `ANDROID_KEYSTORE_PASSWORD`: `praxis123`
     - `ANDROID_KEY_ALIAS`: `praxis`
     - `ANDROID_KEY_PASSWORD`: `praxis123`

### 2. 确保代码已提交

```bash
# 检查是否有未提交的更改
git status

# 如果有更改，提交它们
git add .
git commit -m "chore: prepare for test build"
git push
```

## 测试步骤

### 方法 1: 使用发布脚本（推荐）

```bash
# 创建测试版本 tag
./scripts/release.sh 1.0.0-test
```

脚本会自动：
1. 更新 `pubspec.yaml` 中的版本号
2. 创建并推送 tag `v1.0.0-test`
3. 触发 GitHub Actions 自动构建

### 方法 2: 手动创建 tag

```bash
# 1. 创建 tag
git tag v1.0.0-test

# 2. 推送 tag 到远程
git push origin v1.0.0-test
```

## 查看构建进度

1. **访问 GitHub Actions**:
   - 在 GitHub 仓库页面，点击 "Actions" 标签
   - 找到 "Build and Release" workflow
   - 点击查看执行详情

2. **查看构建日志**:
   - 点击 "Build Android" job 查看 Android 构建日志
   - 检查是否有错误

3. **预期结果**:
   - ✅ `build-android` job 应该成功完成
   - ✅ 应该生成 APK 和 AAB 文件
   - ✅ 在 Releases 页面应该看到新创建的 Release
   - ✅ Release 中应该包含 APK 和 AAB 文件

## 验证构建产物

### 在 GitHub Releases 页面

1. 访问仓库的 "Releases" 页面
2. 找到 `v1.0.0-test` release
3. 检查是否包含以下文件：
   - `app-release.apk` - Android APK 文件
   - `app-release.aab` - Android App Bundle 文件

### 下载并测试

1. **下载 APK**:
   - 从 Releases 页面下载 `app-release.apk`
   - 安装到 Android 设备测试

2. **验证签名**:
   ```bash
   # 使用 jarsigner 验证 APK 签名
   jarsigner -verify -verbose -certs app-release.apk
   ```

## 常见问题排查

### 问题 1: 构建失败，提示找不到密钥库

**原因**: GitHub Secrets 未正确配置

**解决方案**:
1. 检查 Secrets 是否已添加
2. 确认 `ANDROID_KEYSTORE_BASE64` 的值是否正确（base64 编码）
3. 重新运行 `./scripts/setup_github_secrets.sh` 获取正确的编码

### 问题 2: 签名失败，密码错误

**原因**: Secrets 中的密码不正确

**解决方案**:
1. 检查以下 Secrets 的值：
   - `ANDROID_KEYSTORE_PASSWORD`: 应该是 `praxis123`
   - `ANDROID_KEY_PASSWORD`: 应该是 `praxis123`
   - `ANDROID_KEY_ALIAS`: 应该是 `praxis`

### 问题 3: 构建成功但没有上传到 Release

**原因**: Release 创建或上传步骤失败

**解决方案**:
1. 检查 GitHub Actions 日志中的 "Upload APK to Release" 步骤
2. 确认 `GITHUB_TOKEN` 有足够的权限
3. 检查 tag 是否已正确推送

### 问题 4: 构建时间过长

**原因**: 首次构建需要下载依赖和设置环境

**解决方案**:
- 这是正常的，首次构建可能需要 10-20 分钟
- 后续构建会使用缓存，速度会更快

## 成功标志

如果看到以下情况，说明配置成功：

✅ **GitHub Actions**:
- `build-android` job 显示绿色 ✓
- 所有步骤都成功完成

✅ **GitHub Releases**:
- 新创建的 Release 包含 APK 和 AAB 文件
- 文件大小合理（APK 通常 20-50MB，AAB 稍小）

✅ **下载页面**:
- `docs/download.html` 自动显示最新版本
- 下载链接可以正常使用

## 下一步

测试成功后，您可以：

1. **删除测试 tag**（可选）:
   ```bash
   git tag -d v1.0.0-test
   git push origin :refs/tags/v1.0.0-test
   ```

2. **准备正式发布**:
   - 更新版本号
   - 创建正式版本 tag
   - 使用 `./scripts/release.sh 1.0.0` 发布正式版本

## 相关文档

- [Android 签名配置指南](ANDROID_SIGNING_SETUP.md)
- [发布配置指南](RELEASE_SETUP.md)
- [签名快速开始](SIGNING_QUICK_START.md)

