# 签名配置总结

## ✅ Android 签名配置 - 已完成

### 已完成的工作

1. ✅ **生成密钥库**: `android/app/keystore.jks`
   - 别名: `praxis`
   - 密码: `praxis123` (默认值)

2. ✅ **更新构建配置**: `android/app/build.gradle`
   - 已添加签名配置支持
   - 支持从 `key.properties` 读取签名信息

3. ✅ **创建本地配置**: `android/key.properties`
   - 已配置密钥库路径和密码
   - 已在 `.gitignore` 中，不会被提交

4. ✅ **创建辅助脚本**: `scripts/setup_github_secrets.sh`
   - 自动生成 base64 编码
   - 显示需要添加的 GitHub Secrets

### 下一步：配置 GitHub Secrets

运行以下命令获取配置信息：

```bash
./scripts/setup_github_secrets.sh
```

然后在 GitHub 仓库中添加以下 Secrets：

| Secret 名称 | 值 |
|------------|-----|
| `ANDROID_KEYSTORE_BASE64` | 从脚本输出复制（已自动复制到剪贴板） |
| `ANDROID_KEYSTORE_PASSWORD` | `praxis123` |
| `ANDROID_KEY_ALIAS` | `praxis` |
| `ANDROID_KEY_PASSWORD` | `praxis123` |

## 安全配置

✅ **已确保**:
- 密钥库文件 (`*.jks`, `*.keystore`) 已在 `.gitignore` 中
- 配置文件 (`key.properties`) 已在 `.gitignore` 中

⚠️ **建议**:
- 更改默认密码 `praxis123` 为更安全的密码
- 定期备份密钥库和证书文件到安全位置
- 限制 GitHub Secrets 的访问权限

## 测试配置

配置完成后，可以测试发布流程：

```bash
# 使用发布脚本
./scripts/release.sh 1.0.0-test

# 或手动创建 tag
git tag v1.0.0-test
git push origin v1.0.0-test
```

然后在 GitHub Actions 中查看构建进度。

## 相关文档

- [Android 签名配置指南](ANDROID_SIGNING_SETUP.md)
- [签名快速开始](SIGNING_QUICK_START.md)
- [发布配置指南](RELEASE_SETUP.md)

## 辅助工具

- `scripts/setup_github_secrets.sh` - 生成 GitHub Secrets 配置
- `scripts/release.sh` - 一键发布脚本

