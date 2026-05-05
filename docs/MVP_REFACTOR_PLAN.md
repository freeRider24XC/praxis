# Praxis MVP 重构方案

> 目标：在现有 Praxis 项目基础上，完成一次聚焦 MVP 的产品重构，验证“AI 帮用户把模糊目标拆成一周内可执行行动”这件事是否成立。

---

## 1. 结论

Praxis 适合重构，不适合推倒重来。

原因：

- 现有项目已经具备可复用的基础设施：Flutter、GetX、Hive、主题、多语言、AI 配置、路由都已接通。
- 现有核心模型 `Todo / Goal / Project / FocusSession` 可继续作为业务骨架。
- 新产品方向与旧项目并非断裂，而是“任务管理器”向“行动型人生系统”的升级。

建议采用：

- `保留底层能力`
- `重做上层产品结构`
- `先并行新增，再逐步替换旧页面`

---

## 2. MVP 定义

### 2.1 MVP 一句话定义

Praxis MVP 是一个 AI 驱动的行动型成长 App：

用户选择一个当前最想改善的人生领域，输入一个模糊目标，AI 帮他拆成目标、里程碑和本周任务；用户每天通过首页推进任务，并通过轻量反馈和每日复盘持续回来使用。

### 2.2 MVP 验证的问题

MVP 只验证三件事：

1. AI 生成的计划是否足够可执行
2. 首页是否能让用户每天知道自己该做什么
3. XP 与复盘是否能提升用户连续使用意愿

### 2.3 目标用户

首批只服务这类用户：

- 22-35 岁
- 有明确改善意愿，但执行不稳定
- 有模糊目标，不知道如何拆成今天能做的事
- 愿意尝试 AI，但不愿意维护复杂系统

典型场景：

- 想开始健身，但总是三天打鱼
- 想学一门技能，但不知道从哪里切
- 想做副业作品，但没有稳定推进节奏
- 想改善作息、阅读、输出习惯

---

## 3. MVP 核心闭环

用户完整体验路径：

1. 首次进入 App
2. 选择一个当前重点领域
3. 输入一个 1-3 个月目标
4. AI 追问 2-3 个必要问题
5. AI 生成目标、里程碑和本周任务
6. 用户确认后写入系统
7. 每天打开首页查看今天最重要的任务
8. 完成任务获得 XP 和进度反馈
9. 晚上完成超轻量复盘
10. 第二天继续回来推进

如果这条链顺了，MVP 就成立。

---

## 4. MVP 产品范围

### 4.1 必做模块

#### A. Onboarding

首次使用只做 4 步：

1. 选择当前重点领域
2. 输入一个 1-3 个月目标
3. 选择每周可投入时间
4. 进入 AI 拆解流程

原则：

- 不做使命/愿景/价值观
- 不做复杂人格测试
- 不做太长的引导

#### B. AI 规划页

用户输入目标后，AI 完成：

- 识别目标所属领域
- 判断目标是否过大或过模糊
- 追问 2-3 个关键信息
- 输出结构化行动方案

输出内容：

- 一个 Goal
- 2-4 个里程碑
- 一个 Project
- 本周 3-5 个 Todo
- 建议优先级

用户必须可以编辑后确认，不能直接自动落库。

#### C. Dashboard 首页

首页是 MVP 的核心界面。

必须包含：

- 当前等级
- 当前 XP 进度
- streak 连续活跃天数
- 今日最重要 3 件事
- 当前重点领域进度
- 一张 AI 建议卡片

首页目标：

- 用户 5 秒内知道“我今天该干什么”

#### D. Goal 详情页

展示：

- 目标标题和周期
- 里程碑
- 关联项目
- 本周任务
- 目标当前进度

先不做复杂 OKR 视图。

#### E. Daily Review

每天晚上只问 3 个问题：

1. 今天完成了什么
2. 今天卡住了什么
3. 明天最重要的一件事是什么

提交后：

- 记录复盘
- 奖励 XP
- 返回一句简短 AI 点评

### 4.2 暂不进入 MVP 的内容

以下内容建议第二阶段再做：

- 周报 / 月报
- 成就系统完整版
- 复杂等级称号体系
- 复杂五维雷达图
- 云同步
- 开放式聊天型 AI 陪伴
- Notion 双向同步
- 虚拟货币 / 商店 / 角色职业系统

---

## 5. MVP 信息架构

建议底部导航调整为：

1. 首页
2. 领域
3. 目标
4. 个人

说明：

- 首页承担“今日推进”
- 领域页承担“当前重点领域 + 五领域概览”
- 目标页承担“Goal / Project 管理”
- 个人页承担“设置 / AI 配置 / 复盘入口 / 统计入口”

---

## 6. MVP 数据模型

### 6.1 复用现有模型

- `Todo`
- `Goal`
- `Project`
- `FocusSession`

### 6.2 新增最小模型

#### LifeDomain

建议字段：

```dart
class LifeDomain {
  String id;
  String name;
  String icon;
  String color;
}
```

#### UserProfile

建议字段：

```dart
class UserProfile {
  String id;
  String? focusedDomainId;
  int totalXp;
  int level;
  int streakDays;
  int weeklyCapacityHours;
  DateTime? lastActiveDate;
  DateTime createdAt;
  DateTime updatedAt;
}
```

#### XpEvent

建议字段：

```dart
class XpEvent {
  String id;
  int xp;
  String source;
  String sourceId;
  String? domainId;
  String description;
  DateTime createdAt;
}
```

#### DailyReview

建议字段：

```dart
class DailyReview {
  String id;
  DateTime date;
  String? whatDone;
  String? blockers;
  String? topPriorityTomorrow;
  int xpEarned;
  bool isCompleted;
  DateTime createdAt;
}
```

### 6.3 对现有模型的最小修改

#### Goal

新增：

- `domainId`

#### Project

新增：

- `domainId`

#### Todo

两种方案二选一：

1. 直接新增 `domainId`
2. 不加字段，运行时通过 `Project / Goal` 继承

建议 MVP 采用：

- `Todo` 直接新增 `domainId`

原因：

- 首页聚合更简单
- XP 记账更直接
- AI 创建 Todo 时可直接归类

---

## 7. MVP AI 设计

### 7.1 AI 在 MVP 里的职责

MVP 只做 3 类 AI 能力：

1. 目标拆解
2. 今日优先级建议
3. 每日复盘总结

### 7.2 不建议保留的现状

当前 AI 流程基于“自然语言回复 + 文本格式提取”。

问题：

- 输出不稳定
- 容易解析失败
- 不适合作为核心工作流

### 7.3 建议的新 AI 架构

分为四层：

#### AiProvider

负责和模型 API 通信，保留当前多模型兼容能力。

#### AiUseCaseService

新增场景化服务：

- `planGoal()`
- `suggestTodayPlan()`
- `reviewDay()`

#### AiSchemaParser

只解析结构化 JSON，不再靠正则猜自然语言。

#### AiActionExecutor

把 AI 输出转换为：

- `Goal`
- `Project`
- `Todo`
- `DailyReview`

并进入用户确认流程。

### 7.4 建议的 AI 输出结构

```json
{
  "intent": "goal_plan",
  "domain": "health",
  "goal": {
    "title": "3个月内建立稳定跑步习惯",
    "targetDate": "2026-08-31"
  },
  "milestones": [
    "连续2周每周跑2次",
    "完成一次5公里轻松跑"
  ],
  "project": {
    "name": "跑步习惯建立计划"
  },
  "todos": [
    {"title": "周一慢跑2公里", "priority": "high"},
    {"title": "周三拉伸20分钟", "priority": "medium"},
    {"title": "周六快走40分钟", "priority": "medium"}
  ],
  "followUpQuestions": []
}
```

原则：

- AI 返回结构化数据
- 业务层负责显示和确认
- 数据库写入必须由用户确认触发

---

## 8. MVP 游戏化策略

MVP 的游戏化必须轻量。

### 8.1 必做

- XP
- 等级
- streak
- 完成任务即时反馈

### 8.2 XP 建议规则

| 行为 | XP |
|------|----|
| 完成 Todo | +10 |
| 完成 Goal | +100 |
| 完成每日复盘 | +20 |
| 连续活跃一天 | streak +1 |

MVP 先用简单规则，不做复杂加成。

### 8.3 暂不做

- 成就树
- 角色职业体系
- 商店
- 复杂称号
- 虚拟货币

---

## 9. 页面与模块实施方案

### 9.1 现有代码建议处理方式

#### 保留

- `lib/main.dart`
- `lib/common/services/database_service.dart`
- `lib/common/ai/providers/openai_provider.dart`
- `lib/common/ai/services/ai_config_service.dart`
- `lib/common/models/todo.dart`
- `lib/common/models/goal.dart`
- `lib/common/models/project.dart`
- `lib/common/models/focus_session.dart`
- `lib/common/style/design_tokens.dart`

#### 新建并逐步替换

- `lib/pages/dashboard/`
- `lib/pages/life_domains/`
- `lib/pages/review/`
- `lib/common/models/life_domain.dart`
- `lib/common/models/user_profile.dart`
- `lib/common/models/xp_event.dart`
- `lib/common/models/daily_review.dart`
- `lib/common/services/xp_service.dart`
- `lib/common/services/ai_use_case_service.dart`

#### 逐步边缘化

- 当前 `HomePage`
- 当前 `ManagementPage`
- 当前 `StatsPage`
- 当前 `AiInteractionPage` 的纯聊天定位

#### 后续清理

- `lib/pages/home/view.dart`
- `lib/pages/home/controller.dart`

这两份更像历史遗留实现，后续应清理。

---

## 10. 重构阶段规划

### 阶段 0：准备期

目标：

- 冻结产品方向
- 明确命名
- 整理旧页面边界

产出：

- 确认 MVP 范围
- 确认数据模型
- 确认 AI 结构化方案

### 阶段 1：数据层改造

目标：

- 建立领域、用户档案、XP 事件、复盘的数据基础

任务：

- 新增 4 个 Hive 模型
- 注册 Adapter
- 打开新 Box
- 给 `Goal / Project / Todo` 增加 `domainId`
- 增加 `UserProfile` 初始化逻辑

完成标准：

- App 启动后可读取和写入新模型
- 旧数据不崩

### 阶段 2：产品壳重构

目标：

- 建立新导航和新页面骨架

任务：

- 改造 `MainPage`
- 新建 `DashboardPage`
- 新建 `DomainsPage`
- 新建 `ReviewPage`
- 保留旧页面作为过渡

完成标准：

- 用户可进入新导航
- 新页面可显示基础占位和真实数据

### 阶段 3：AI 目标拆解闭环

目标：

- 打通 MVP 最大价值点

任务：

- 新增 `AiUseCaseService.planGoal()`
- 改造 prompt 为结构化输出
- 新增解析器
- 增加“确认创建”页面
- 落库 Goal / Project / Todo / domainId

完成标准：

- 用户输入一句目标，能稳定生成并确认写入任务系统

### 阶段 4：首页闭环

目标：

- 让用户每天打开就知道该做什么

任务：

- Dashboard 展示 XP、等级、今日 3 件事
- 统计本周当前重点领域进度
- 接入今日 AI 建议

完成标准：

- 首页成为新的默认使用入口

### 阶段 5：复盘与收口

目标：

- 建立最小行为闭环并开始替换旧逻辑

任务：

- Daily Review 页面
- XP 奖励
- streak 更新
- 清理部分旧首页逻辑

完成标准：

- 用户可完成“早上看首页、晚上做复盘”的闭环

---

## 11. 开发优先级

### P0

- 新数据模型
- 数据库扩展
- `domainId` 接入
- Onboarding 重做
- AI 目标拆解
- Dashboard
- Daily Review
- XP 计算

### P1

- 今日 AI 建议
- Goal 详情增强
- streak 机制
- 领域页聚合统计

### P2

- 成就
- 周报
- Focus 与 XP 深绑定
- 趋势图优化

---

## 12. 第一周建议实施清单

如果要尽快启动，建议第一周只做这些：

### Day 1

- 新建 `LifeDomain / UserProfile / XpEvent / DailyReview`
- 更新 `models/index.dart`
- 更新 `DatabaseService`

### Day 2

- 给 `Todo / Goal / Project` 加 `domainId`
- 处理 Hive type 与字段新增
- 确保现有页面仍可运行

### Day 3

- 新建 `xp_service.dart`
- 实现基础 XP 规则
- 实现 `UserProfile` 初始化与等级计算

### Day 4

- 新建 `DashboardPage`
- 改造 `MainPage` 让首页切换到新 Dashboard

### Day 5

- 新建 `AiUseCaseService`
- 把目标拆解改成结构化输出
- 完成 AI 生成结果确认页的第一版

这五天做完，项目会从“概念讨论”进入“真正开始变形”。

---

## 13. 风险与控制

### 风险 1：范围失控

表现：

- 一口气做五领域平衡、成就、周报、复杂 AI

控制：

- 先只服务一个重点领域
- 先只验证第一周闭环

### 风险 2：AI 输出不稳定

表现：

- AI 回复像聊天，业务对象创建不稳定

控制：

- 强制结构化 JSON
- 加用户确认页
- 落库前做 schema 校验

### 风险 3：旧页面和新页面并存太久

表现：

- 逻辑重复
- 维护成本快速升高

控制：

- 每一阶段结束都定义一个可下线的旧模块

### 风险 4：没有测试保护

表现：

- 小改动影响老逻辑

控制：

- 至少补 3 类测试：
  - 模型序列化
  - XP 计算
  - AI schema 解析

---

## 14. 成功标准

MVP 不用看太多大而全指标，先看这几个：

1. 用户能在 3 分钟内完成首次建档和首个计划创建
2. 用户能看懂首页并知道今天优先做什么
3. AI 生成的任务有真实执行率
4. 用户愿意连续 3 天回来使用

---

## 15. 最终建议

Praxis 这次不是简单迭代，而是一次“产品身份重构”。

但它不需要推倒重来。最合适的方式是：

- 用现有项目承接底层能力
- 用新数据模型承接新产品逻辑
- 用新首页、AI 规划和复盘闭环承接新的用户价值

一句话总结：

`先把一个目标拆成一周行动，再把这一周做顺。`

这就是 Praxis MVP 最应该长成的样子。
