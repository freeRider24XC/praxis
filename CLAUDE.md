# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Praxis 是一个 AI 原生的目标/项目管理应用，接入 DeepSeek、通义千问、GPT 等 AI 工具，通过对话帮助用户制定目标、项目和待办。核心功能包括：目标管理、项目管理、待办事项、专注计时、每日回顾、AI 对话。

**状态管理**: GetX
**Flutter 版本**: 3.32.8 (通过 FVM 管理)

## 常用命令

### 开发
```bash
# 运行应用
flutter run

# 运行特定平台
flutter run -d macos
flutter run -d chrome

# 代码分析
flutter analyze

# 生成代码 (Hive adapters, Freezed 等)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 发布
```bash
# 版本发布 (自动更新版本号、创建 tag、触发 GitHub Actions)
./scripts/release.sh 1.0.0
```

### 测试
```bash
flutter test
# 运行单个测试文件
flutter test test/xp_service_test.dart
```

## 架构

### 目录结构

```
lib/
├── main.dart              # 应用入口，初始化服务
├── common/
│   ├── ai/                # AI 相关 (chat, plan)
│   ├── api/               # API 调用封装
│   ├── components/         # 通用组件
│   ├── constants/         # 常量定义
│   ├── extension/         # Dart 扩展
│   ├── i18n/              # 国际化
│   ├── models/            # 数据模型 (Hive 适配器)
│   ├── routers/           # GetX 路由
│   ├── services/          # 核心服务 (Database, Calendar, Theme, Locale, XP)
│   ├── style/             # 主题样式
│   ├── utils/             # 工具函数
│   └── values/            # 静态资源 (SVG, 图片)
├── pages/                 # 页面，按功能模块组织
│   ├── ai_chat/           # AI 对话页面
│   ├── dashboard/         # 仪表盘
│   ├── goal/              # 目标管理
│   ├── home/              # 首页
│   ├── project/           # 项目管理
│   ├── todo/              # 待办管理
│   └── ...                # 其他页面
└── components/            # 跨模块通用组件
```

### 数据模型

Models 使用 Hive 存储，生成 `.g.dart` 文件：
- `Goal` - 目标
- `Project` - 项目
- `Todo` - 待办
- `FocusSession` - 专注记录
- `DailyReview` - 每日回顾
- `LifeDomain` - 生活领域
- `UserProfile` - 用户资料
- `XpEvent` - XP 事件记录

### 服务层

核心服务位于 `lib/common/services/`：
- `DatabaseService` - 数据库初始化和 Hive 封装
- `CalendarSyncService` - 日历同步
- `LocaleService` - 国际化
- `ThemeService` - 主题管理
- `XpService` - 经验值系统
- `ProfileService` - 用户资料
- `LoggerService` / `ErrorService` - 日志和错误处理

### 路由

使用 GetX 路由，定义在 `lib/common/routers/`。主要页面通过 GetPage 注册，支持路径参数如 `/project/detail/:id`。

### 代码生成

项目使用 build_runner 生成 Hive type adapters。运行 `flutter pub run build_runner build` 生成 `*.g.dart` 文件。这些文件已加入 analyzer 的 exclude 列表。

### 条件导入

应用使用条件导入处理平台差异：
- `app_bootstrap_io.dart` - 原生平台初始化
- `app_bootstrap_stub.dart` - Web 平台存根

## 发布流程

项目使用 GitHub Actions 自动化构建。推送 version tag 时触发构建，产物发布到 GitHub Releases。详见 `scripts/release.sh`。