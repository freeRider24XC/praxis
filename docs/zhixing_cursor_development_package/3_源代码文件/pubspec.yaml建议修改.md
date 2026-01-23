---
AIGC:
    ContentProducer: Minimax Agent AI
    ContentPropagator: Minimax Agent AI
    Label: AIGC
    ProduceID: "00000000000000000000000000000000"
    PropagateID: "00000000000000000000000000000000"
    ReservedCode1: 30460221009d8bdc81c783d5dd6b1905de82c81fcbdf17db2109013635ab4b6ad7ef1fe4d5022100d2cb9bfa6e431911cdfba90e6f1dbb9b4df6f0ce1db992cbfa65f23cb0908b76
    ReservedCode2: 3045022100ec37f6797c6b9f7e28d32f2ce501bd66259cd0af06f69d1619c078d70dce785702202c71033d38aa68e7f0d904dcb9fbbdf337b28503b784e07769afc4bcadf8ce45
---

# pubspec.yaml 修改建议

## 📝 需要修改的内容

基于您的现有 `pubspec.yaml` 文件，以下是需要进行的修改：

## 1. 基本信息更新

```yaml
# 修改前
name: praxis
description: "A new Flutter project."

# 修改后
name: zixing
description: "知行合一，规划人生 - 智能AI规划助手"
```

## 2. 应用版本信息

```yaml
# 建议版本升级
version: 2.0.0+1  # 从 1.0.0+1 升级为主版本
```

## 3. 依赖包检查

您现有的依赖包已经非常完整，建议检查以下包是否需要更新：

```yaml
dependencies:
  # 建议保持现有依赖，这些已经很新
  get: ^4.6.6              # 状态管理
  hive: ^2.2.3             # 本地存储
  hive_flutter: ^1.1.0     # Hive Flutter支持
  fl_chart: ^0.66.0        # 图表库
  table_calendar: ^3.0.9   # 日历组件
  
  # 如果需要添加新功能，可以考虑：
  # flutter_svg: ^2.0.9      # SVG支持（用于图标）
  # cached_network_image: ^3.3.0 # 网络图片缓存
  # shimmer: ^3.0.0         # 加载动画
```

## 4. 开发依赖

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1    # 保持现有
  build_runner: ^2.4.7      # 保持现有
  
  # 建议添加：
  # mockito: ^5.4.0         # 单元测试模拟
  # integration_test:       # 集成测试
```

## 5. Flutter配置

```yaml
flutter:
  uses-material-design: true
  
  # 建议添加assets配置
  assets:
    - assets/images/        # 应用图标
    - assets/icons/         # 图标资源
    - assets/fonts/         # 自定义字体
  
  # 建议添加字体配置
  fonts:
    - family: ZhiXing
      fonts:
        - asset: assets/fonts/ZhiXing-Regular.ttf
        - asset: assets/fonts/ZhiXing-Bold.ttf
          weight: 700
```

## 📋 完整修改示例

```yaml
name: zixing
description: "知行合一，规划人生 - 智能AI规划助手"
version: 2.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.6
  
  # 状态管理
  get: ^4.6.6
  
  # 本地存储
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.3.0
  path: ^1.8.3
  shared_preferences: ^2.2.2
  
  # UI组件
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  animations: ^2.0.11
  
  # 工具
  uuid: ^4.2.1
  collection: ^1.18.0
  
  # 日期时间
  table_calendar: ^3.0.9
  
  # 图表
  fl_chart: ^0.66.0
  
  # 通知
  flutter_local_notifications: ^18.0.1
  
  # 权限
  permission_handler: ^11.1.0
  
  # HTTP
  http: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
  mockito: ^5.4.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
  
  fonts:
    - family: ZhiXing
      fonts:
        - asset: assets/fonts/ZhiXing-Regular.ttf
        - asset: assets/fonts/ZhiXing-Bold.ttf
          weight: 700
```

## ⚠️ 注意事项

1. **备份原文件**: 修改前请备份原始 `pubspec.yaml`
2. **逐步修改**: 建议分步骤修改，每次修改后测试
3. **版本兼容**: 确保依赖包版本兼容性
4. **运行测试**: 修改后运行 `flutter pub get` 和测试

## 🔄 实施步骤

1. 备份当前 `pubspec.yaml` 文件
2. 按照建议修改项目基本信息
3. 更新依赖包版本（如需要）
4. 添加资源文件配置
5. 运行 `flutter pub get`
6. 测试应用正常运行

## 📞 问题排查

如果遇到依赖包冲突：
- 运行 `flutter pub deps` 检查依赖关系
- 运行 `flutter pub upgrade` 更新包版本
- 参考 [Flutter依赖管理文档](https://docs.flutter.dev/development/packages-and-plugins/using-packages)