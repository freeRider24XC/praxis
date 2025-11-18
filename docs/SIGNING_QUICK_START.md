# 签名配置快速开始

本文档提供 Android 签名的快速配置指南。

## Android 签名 ✅ 已完成

Android 签名已配置完成，您只需要在 GitHub 中添加 Secrets。

### 快速配置步骤

1. **运行配置脚本**:
   ```bash
   ./scripts/setup_github_secrets.sh
   ```

2. **复制输出的 base64 编码**

3. **在 GitHub 仓库中添加 Secrets**:
   - 访问：`Settings > Secrets and variables > Actions`
   - 添加以下 4 个 Secrets：
     - `ANDROID_KEYSTORE_BASE64`: 从脚本输出复制
     - `ANDROID_KEYSTORE_PASSWORD`: `praxis123`
     - `ANDROID_KEY_ALIAS`: `praxis`
     - `ANDROID_KEY_PASSWORD`: `praxis123`

### 当前配置信息

- ✅ 密钥库已生成: `android/app/keystore.jks`
- ✅ 构建配置已更新: `android/app/build.gradle`
- ✅ 本地配置文件: `android/key.properties`

详细说明请查看: [Android 签名配置指南](ANDROID_SIGNING_SETUP.md)

## 验证配置

配置完成后，测试发布流程：

```bash
# 创建测试版本 tag
./scripts/release.sh 1.0.0-test
```

或者手动创建 tag：

```bash
git tag v1.0.0-test
git push origin v1.0.0-test
```

然后在 GitHub Actions 中查看构建进度。

## 安全提示

⚠️ **重要**:
- 密钥库和证书文件已自动添加到 `.gitignore`
- 默认密码为 `praxis123`，建议在生产环境使用更安全的密码
- 定期备份密钥库和证书文件到安全位置
- 限制 GitHub Secrets 的访问权限

## 需要帮助？

- Android 配置问题: 查看 [Android 签名配置指南](ANDROID_SIGNING_SETUP.md)
- 发布流程问题: 查看 [发布配置指南](RELEASE_SETUP.md)

