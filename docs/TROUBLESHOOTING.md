# GitHub Actions 构建故障排查指南

## 如何查看构建错误

1. **访问 Actions 页面**
   - 进入：`https://github.com/freeRider24XC/praxis/actions`
   - 点击失败的 workflow 运行

2. **查看具体错误**
   - 点击失败的 job（如 "Build Android"）
   - 展开失败的步骤
   - 查看错误日志

## 常见错误及解决方案

### 1. 依赖解析失败

**错误信息**：
```
Resolving dependencies...
version solving failed
```

**解决方案**：
- 检查 `pubspec.yaml` 中的依赖版本
- 确保 SDK 版本要求兼容
- 运行 `flutter pub get` 本地测试

### 2. Android 构建失败

**可能原因**：
- 缺少签名配置（会使用 debug 签名，通常不会失败）
- Gradle 配置错误
- 代码编译错误

**解决方案**：
1. 检查构建日志中的具体错误
2. 确保 `android/app/build.gradle` 配置正确
3. 检查是否有编译错误

### 3. iOS 构建失败

**可能原因**：
- 缺少证书和配置文件（预期会失败）
- CocoaPods 依赖问题
- Xcode 配置错误

**解决方案**：
- iOS 构建失败是预期的（如果未配置证书）
- 可以暂时忽略 iOS 构建，只关注 Android

### 4. Release 上传失败

**可能原因**：
- GITHUB_TOKEN 权限不足
- Release 已存在

**解决方案**：
- 检查 GitHub token 权限
- 删除已存在的 Release 后重试

## 调试步骤

### 步骤 1: 查看完整错误日志

在 GitHub Actions 页面：
1. 点击失败的 workflow
2. 点击失败的 job
3. 展开每个步骤查看详细日志
4. 复制错误信息

### 步骤 2: 本地复现问题

```bash
# 切换到相同的 Flutter 版本
fvm flutter --version

# 清理并重新获取依赖
fvm flutter clean
fvm flutter pub get

# 尝试本地构建
fvm flutter build apk --release
```

### 步骤 3: 检查配置

- [ ] `pubspec.yaml` 中的版本号是否正确
- [ ] `android/app/build.gradle` 配置是否正确
- [ ] GitHub Secrets 是否已配置（可选）

## 快速修复

如果构建失败，可以：

1. **重新运行 workflow**
   - 在 Actions 页面点击 "Re-run all jobs"

2. **修复代码后重新推送 tag**
   ```bash
   # 删除旧 tag
   git tag -d v1.0.0
   git push origin :refs/tags/v1.0.0
   
   # 修复问题后重新创建 tag
   git tag v1.0.1
   git push origin v1.0.1
   ```

3. **检查 workflow 文件语法**
   - 确保 YAML 格式正确
   - 检查缩进和语法

## 获取帮助

如果问题仍然存在：
1. 复制完整的错误日志
2. 检查本地构建是否成功
3. 查看 GitHub Actions 文档

