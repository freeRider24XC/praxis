# 多语言使用指南

## 概述

本项目使用类型安全的多语言系统，支持IDE自动补全，避免硬编码字符串键。

## 使用方法

### 1. 基本使用（无参数）

使用 `AppStrings` 类提供的常量键，配合 GetX 的 `.tr` getter：

```dart
import 'package:praxis/common/i18n/app_strings.dart';
import 'package:get/get.dart';

// ✅ 正确：类型安全，IDE可以自动补全
Text(AppStrings.projectManagement.tr)

// ❌ 错误：硬编码字符串，没有IDE提示
Text('projectManagement'.tr)
```

### 2. 带参数的翻译

使用 `.trNamed()` 扩展方法处理带参数的翻译：

```dart
// 翻译键定义：'daysRemaining': '@days天'
AppStrings.daysRemaining.trNamed({'days': '5'})
// 结果: "5天" 或 "5 days"

// 翻译键定义：'progressPercentage': '@percentage%'
AppStrings.progressPercentage.trNamed({'percentage': '80'})
// 结果: "80%" 

// 翻译键定义：'noProjectsWithStatus': '没有@status的项目'
AppStrings.noProjectsWithStatus.trNamed({'status': '进行中'})
// 结果: "没有进行中的项目" 或 "No Active projects"
```

### 3. 添加新的翻译键

1. 在 `lib/common/i18n/app_strings.dart` 中添加常量：
```dart
class AppStrings {
  // ...
  static const String myNewKey = 'myNewKey';
}
```

2. 在 `lib/common/i18n/translations.dart` 中添加翻译：
```dart
'en_US': {
  // ...
  'myNewKey': 'My New Text',
},
'zh_CN': {
  // ...
  'myNewKey': '我的新文本',
},
```

3. 在代码中使用：
```dart
Text(AppStrings.myNewKey.tr)
```

## 优势

1. **类型安全**：编译时检查，避免拼写错误
2. **IDE自动补全**：输入 `AppStrings.` 后可以看到所有可用的键
3. **易于重构**：重命名键时IDE可以自动更新所有引用
4. **代码提示**：鼠标悬停在键上可以看到对应的翻译值

## 注意事项

- `.tr` 是 getter，不是方法，不需要括号：`AppStrings.key.tr` ✅
- `.trNamed()` 是方法，需要括号和参数：`AppStrings.key.trNamed({'param': 'value'})` ✅
- 参数占位符使用 `@key` 格式，例如：`@days`、`@status`、`@percentage`

