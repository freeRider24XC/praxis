# 发布配置指南

本指南将帮助您配置 GitHub Actions 自动打包和发布流程。

## 功能说明

当您推送一个版本 tag（格式：`v*`，如 `v1.0.0`）到 GitHub 时，会自动触发以下流程：

1. **Android 打包**：自动构建 APK 和 AAB 文件
2. **创建 Release**：在 GitHub 上创建 Release 并上传构建产物
3. **更新下载链接**：自动更新 `docs/version.json` 文件，下载页面会自动读取

> **注意**：iOS 打包功能已暂时禁用，当前仅支持 Android 打包。

## 配置步骤

### 1. Android 签名配置（可选但推荐）

#### 生成密钥库

```bash
keytool -genkey -v -keystore android/app/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias praxis
```

#### 配置 GitHub Secrets

在 GitHub 仓库的 Settings > Secrets and variables > Actions 中添加以下 secrets：

- `ANDROID_KEYSTORE_BASE64`: 将 `keystore.jks` 文件进行 base64 编码
  ```bash
  base64 -i android/app/keystore.jks | pbcopy
  ```
- `ANDROID_KEYSTORE_PASSWORD`: 密钥库密码
- `ANDROID_KEY_ALIAS`: 密钥别名（通常是 `praxis`）
- `ANDROID_KEY_PASSWORD`: 密钥密码

#### 更新 Android 构建配置

编辑 `android/app/build.gradle`，添加签名配置：

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... 其他配置 ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... 其他配置 ...
        }
    }
}
```

### 2. 使用流程

#### 创建版本 tag 并推送

```bash
# 1. 确保代码已提交
git add .
git commit -m "chore: prepare for release v1.0.0"

# 2. 创建并推送 tag
git tag v1.0.0
git push origin v1.0.0

# 或者一次性推送所有 tags
git push origin --tags
```

#### 查看构建进度

1. 在 GitHub 仓库页面，点击 "Actions" 标签
2. 查看 "Build and Release" workflow 的执行状态
3. 构建完成后，在 "Releases" 页面可以看到新创建的 Release

#### 下载构建产物

- 在 GitHub Releases 页面直接下载
- 访问 `docs/download.html` 页面，会自动显示最新版本的下载链接

## 版本号格式

版本号格式应遵循语义化版本（Semantic Versioning）：

- 格式：`v主版本号.次版本号.修订号`
- 示例：`v1.0.0`, `v1.2.3`, `v2.0.0-beta.1`

## 注意事项

1. **首次使用**：如果没有配置签名，Android 会使用 debug 签名
2. **密钥安全**：永远不要将密钥文件提交到 Git 仓库
3. **版本号**：确保 `pubspec.yaml` 中的版本号与 tag 一致
4. **构建时间**：首次构建可能需要较长时间，后续构建会使用缓存加速

## 故障排除

### Android 构建失败

- 检查 Flutter 版本是否匹配
- 确认 Java 版本为 17
- 检查签名配置是否正确

### 下载链接不更新

- 确认 `update-download-links` job 执行成功
- 检查 `docs/version.json` 文件是否已更新
- 确认 GitHub token 有写入权限

## 相关文件

- `.github/workflows/release.yml`: GitHub Actions 工作流配置
- `docs/version.json`: 版本信息和下载链接
- `docs/download.html`: 下载页面

