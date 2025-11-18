# Android 签名配置指南

本指南说明如何配置 Android 应用的签名，以便在 GitHub Actions 中自动构建已签名的 APK 和 AAB 文件。

## 当前配置状态

✅ **已完成**:
- 已生成密钥库文件：`android/app/keystore.jks`
- 已配置 `build.gradle` 支持签名
- 已创建 `key.properties` 文件

## 密钥库信息

- **密钥库文件**: `android/app/keystore.jks`
- **密钥别名**: `praxis`
- **密钥库密码**: `praxis123` (默认值，建议更改)
- **密钥密码**: `praxis123` (默认值，建议更改)

⚠️ **安全提示**: 当前使用的是默认密码，建议在生产环境中使用更安全的密码。

## 配置 GitHub Secrets

### 方法 1: 使用辅助脚本（推荐）

运行以下命令：

```bash
./scripts/setup_github_secrets.sh
```

脚本会自动生成 base64 编码并显示需要添加的 Secrets。

### 方法 2: 手动配置

1. **生成密钥库的 base64 编码**:

   ```bash
   base64 -i android/app/keystore.jks | pbcopy  # macOS (自动复制到剪贴板)
   # 或
   base64 -i android/app/keystore.jks            # Linux (显示在终端)
   ```

2. **在 GitHub 仓库中添加 Secrets**:

   访问：`Settings > Secrets and variables > Actions > New repository secret`

   添加以下 Secrets：

   | Secret 名称 | 值 | 说明 |
   |------------|-----|------|
   | `ANDROID_KEYSTORE_BASE64` | 密钥库的 base64 编码 | 从上面的命令复制 |
   | `ANDROID_KEYSTORE_PASSWORD` | `praxis123` | 密钥库密码 |
   | `ANDROID_KEY_ALIAS` | `praxis` | 密钥别名 |
   | `ANDROID_KEY_PASSWORD` | `praxis123` | 密钥密码 |

## 本地构建测试

配置完成后，您可以在本地测试签名构建：

```bash
# 构建已签名的 APK
flutter build apk --release

# 构建已签名的 AAB (用于 Google Play)
flutter build appbundle --release
```

构建产物位置：
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 更改密钥库密码（可选）

如果您想更改默认密码，可以：

1. **生成新的密钥库**:

   ```bash
   keytool -genkey -v \
     -keystore android/app/keystore.jks \
     -keyalg RSA \
     -keysize 2048 \
     -validity 10000 \
     -alias praxis \
     -storepass YOUR_NEW_STORE_PASSWORD \
     -keypass YOUR_NEW_KEY_PASSWORD \
     -dname "CN=Praxis, OU=Development, O=Praxis, L=Beijing, ST=Beijing, C=CN"
   ```

2. **更新 `android/key.properties`**:

   ```properties
   storePassword=YOUR_NEW_STORE_PASSWORD
   keyPassword=YOUR_NEW_KEY_PASSWORD
   keyAlias=praxis
   storeFile=app/keystore.jks
   ```

3. **更新 GitHub Secrets** 中的密码

## 验证配置

配置完成后，当您推送版本 tag 时，GitHub Actions 会：

1. ✅ 自动从 Secrets 读取密钥库信息
2. ✅ 使用密钥库签名 APK 和 AAB
3. ✅ 上传已签名的构建产物到 Releases

## 安全最佳实践

1. ✅ **密钥库文件已在 `.gitignore` 中**，不会被提交到仓库
2. ✅ **`key.properties` 文件也在 `.gitignore` 中**
3. ⚠️ **建议更改默认密码**为更安全的密码
4. ⚠️ **定期备份密钥库文件**到安全位置
5. ⚠️ **限制 GitHub Secrets 的访问权限**

## 故障排除

### 问题: 构建失败，提示找不到密钥库

**解决方案**: 确保 GitHub Secrets 中的 `ANDROID_KEYSTORE_BASE64` 已正确设置。

### 问题: 签名失败，密码错误

**解决方案**: 检查 GitHub Secrets 中的密码是否正确：
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

### 问题: 本地构建成功，但 GitHub Actions 失败

**解决方案**: 
1. 检查 Secrets 是否已正确添加
2. 确认 base64 编码完整（没有截断）
3. 查看 GitHub Actions 日志获取详细错误信息

## 相关文件

- `android/app/build.gradle`: 构建配置
- `android/key.properties`: 本地签名配置（不提交到 Git）
- `android/app/keystore.jks`: 密钥库文件（不提交到 Git）
- `.github/workflows/release.yml`: GitHub Actions 工作流

