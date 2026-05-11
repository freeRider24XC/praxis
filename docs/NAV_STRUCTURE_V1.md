# Praxis MVP 四主导航页结构稿

> 代码基线：`630e07d` · 依据：`PRODUCT_BLUEPRINT_V1.md` 第13章（若与 `SPEC.md` 冲突，以蓝图第13章为准）

---

## 0. 设计依据速查

| 规范来源 | 关键结论 |
|---------|---------|
| 蓝图第13.2章 | 主导航 = 首页 / 目标 / 项目 / 个人 |
| 蓝图第6.4执行层 | 首页 = 主目标 + 当前项目 + 今日事项 |
| 蓝图第6.4进度规则 | Project进度 = 事项完成率；Goal进度 = 项目集合事项完成率 |
| 蓝图第13.5边界规则 | 目标页只看结果与关联项目，不替代项目页 |

---

## 1. 首页（Dashboard）

### 1.1 模块清单

```
┌─────────────────────────────────┐
│  ⓵ 主目标卡片                    │  ← 当前主目标 + 领域标签 + 目标进度 %
│  ⓶ 当前项目卡片                  │  ← 优先级最高项目 + 状态 + 进度 %
│  ⓷ 今日事项列表                  │  ← 来自当前项目，优先级排序
│  ⓸ 成长与犒赏摘要横条            │  ← XP进度 + 等级 + 犒赏点余额
│  ⓹ 复盘入口按钮                  │  ← "今日复盘" / 或展示已复盘状态
└─────────────────────────────────┘
```

### 1.2 布局规范（Flutter）

```
SafeArea
  └─ CustomScrollView (slivers)
       ├─ SliverToBoxAdapter: 主目标卡片
       │    height: 88pt, padding: 16pt, radius: 12pt
       │    左侧: 目标标题(fontSize:16, fontWeight:600) + 领域标签 Chip
       │    右侧: 圆形进度指示器(progress%, 字号14)
       ├─ SliverToBoxAdapter: 当前项目卡片
       │    height: 72pt, padding: 16pt, radius: 12pt
       │    左侧: 项目名(fontSize:15, fontWeight:500) + 状态Badge
       │    右侧: 进度条(宽80pt, 高6pt, radius:3)
       ├─ SliverToBoxAdapter: 成长摘要横条
       │    height: 48pt, padding: 12pt horizontal
       │    三列: XP进度条 | 等级徽章 | 犒赏点余额
       ├─ SliverToBoxAdapter: 标题 "今日事项" (fontSize:14, color:#94A3B8)
       ├─ SliverList: 今日事项列表
       │    每项height: 56pt, leftIcon:Checkbox, title:fontSize:14
       │    trailing: 优先级标签 / 截止时间
       ├─ SliverToBoxAdapter: 复盘入口按钮
       │    全宽, height:48pt, radius:12pt, 主色调填充
       └─ SliverPadding(bottom: 80pt) ← 避开底部导航
```

### 1.3 关键数值

| 元素 | 字号 | 字重 | 颜色 |
|-----|-----|-----|-----|
| 主目标标题 | 16pt | 600 | onSurface |
| 项目名称 | 15pt | 500 | onSurface |
| 事项标题 | 14pt | 400 | onSurface |
| 进度数字 | 14pt | 500 | primary |
| 次要文字 | 12pt | 400 | textSecondary |
| 摘要横条背景 | — | — | surface, radius:12 |

### 1.4 组件清单

- `GoalSummaryCard`（新建）：主目标展示卡片，含进度圆环
- `ProjectBannerCard`（新建）：当前项目横幅，含状态Badge和进度条
- `GrowthSummaryBar`（新建）：XP/等级/犒赏点三合一横条
- `TodoListItem`（已有）：复用于今日事项，可新增 `showProjectChip` 参数
- `ReviewEntryButton`（新建）：复盘入口按钮

---

## 2. 目标页（Goal）

### 2.1 模块清单

```
┌─────────────────────────────────┐
│  ⓵ 当前主目标大卡                │  ← 置顶，最大面积，含进度
│  ⓶ 进行中目标列表               │  ← 卡片列表，含关联项目数
│  ⓷ 已完成目标折叠区（可收起）     │  ← 历史存档
└─────────────────────────────────┘
```

### 2.2 布局规范（Flutter）

```
Scaffold
  ├─ AppBar: title="目标", actions=[添加按钮]
  └─ ListView(padding:16)
       ├─ 主目标大卡 (当有currentGoal时显示)
       │    Card, padding:16pt, radius:12
       │    GoalTitle(fontSize:18, fontWeight:600)
       │    领域Chip + 截止日期
       │    线性进度条 + %数字
       │    关联项目数标签 (e.g. "3个项目")
       │    → 点击进入 GoalDetailPage
       ├─ SectionTitle: "进行中的目标"
       ├─ ...进行中Goal卡片列表 (每个height:~100pt)
       │    GoalTitle + 领域标签 + 进度条 + 关联项目数
       ├─ ExpansionTile: "已完成目标"
       │    ...已完成Goal卡片列表 (简化展示)
       └─ EmptyState (当无目标时)
```

### 2.3 关键数值

| 元素 | 字号 | 字重 | 颜色 |
|-----|-----|-----|-----|
| 主目标标题 | 18pt | 600 | onSurface |
| 目标列表标题 | 15pt | 500 | onSurface |
| 进度数字 | 13pt | 500 | primary |
| 关联项目数 | 12pt | 400 | textSecondary |
| 间距基准 | 16pt / 12pt / 8pt 网格 |

### 2.4 组件清单

- `MainGoalHeroCard`（新建）：置顶主目标大卡，含完整进度信息
- `GoalListCard`（已有，重用）：进行中/已完成目标卡片
- `Goal关联ProjectChip`（新建）：显示"3个项目"这类聚合信息

### 2.5 交互边界

- **目标页只展示结果与关联项目**：不直接展示事项列表
- **点击目标卡 → GoalDetailPage**：查看目标详情和关联项目
- **点击关联项目 → ProjectDetailPage**：进入项目执行层
- **禁止在目标页内直接操作事项**

---

## 3. 项目页（Project）

### 3.1 模块清单

```
┌─────────────────────────────────┐
│  ⓵ 视图切换 + 状态筛选 Toolbar  │  ← Grid/List切换，状态过滤器
│  ⓶ 项目卡片网格/列表             │  ← 进度 + 状态 + 截止时间 + 事项数
│  ⓷ FloatingActionButton        │  ← 新建项目
└─────────────────────────────────┘
```

### 3.2 布局规范（Flutter）

```
Scaffold
  ├─ AppBar: title="项目", actions=[视图切换Icon, 筛选PopupMenu]
  ├─ Body:
  │    GridView (2列, crossAxisSpacing:12, mainAxisSpacing:12)
  │    或 ListView (当切换为列表视图时)
  │    每张项目卡片:
  │         Card, padding:16pt, radius:12, minHeight:140pt
  │         ├─ 项目名称(fontSize:16, fontWeight:600)
  │         ├─ 状态Badge (active/paused/completed)
  │         ├─ 进度条 (线性, 高4pt, radius:2)
  │         ├─ 截止日期 (fontSize:12, color:textSecondary)
  │         ├─ 事项统计 "3/8事项" (fontSize:12)
  │         └─ 领域标签Chip
  └─ FAB: Icons.add, onPressed→AddProjectPage
```

### 3.3 关键数值

| 元素 | 字号 | 字重 | 颜色 |
|-----|-----|-----|-----|
| 项目名称 | 16pt | 600 | onSurface |
| 状态Badge | 11pt | 500 | 状态对应语义色 |
| 进度% | 13pt | 500 | primary |
| 截止日期 | 12pt | 400 | textSecondary |
| 卡片间距 | 12pt × 12pt（网格）|
| 卡片内边距 | 16pt |
| 卡片圆角 | 12pt |

### 3.4 组件清单

- `ProjectGridCard`（新建）：项目网格卡片，含进度、状态、截止
- `ProjectListTile`（已有，改造）：列表视图适配
- `ProjectStatusBadge`（已有）：状态标签
- `ProjectProgressBar`（新建）：统一的项目进度条组件

### 3.5 交互边界

- **项目页是执行主容器**：承载事项管理的核心职责
- **点击卡片 → ProjectDetailPage**：查看事项列表和执行操作
- **禁止将项目页做成第二个首页**：不在此处重复展示主目标

---

## 4. 个人页（Profile）

### 4.1 模块清单

```
┌─────────────────────────────────┐
│  ⓵ 等级与XP模块                  │  ← 等级徽章 + 称号 + XP进度条
│  ⓶ 犒赏点余额模块                │  ← 当前余额 + 快捷进入奖励商店
│  ⓷ 连续活跃天数                  │  ← 火焰图标 + 天数
│  ⓸ 重点领域信息卡片              │  ← 当前聚焦领域 + 每周可投入时间
│  ⓹ 统计数据网格                  │  ← 已完成任务数 / 专注时长 / 目标数
│  ⓺ 设置入口                     │  ← 跳转SettingsPage
└─────────────────────────────────┘
```

### 4.2 布局规范（Flutter）

```
Scaffold
  ├─ AppBar: title="个人", actions=[设置IconButton→SettingsPage]
  └─ ListView(padding:16)
       ├─ 等级卡片 (Container, radius:32, 全宽)
       │    背景: primary渐变 或 surface+阴影
       │    Lv.数字(fontSize:32, fontWeight:700)
       │    称号(fontSize:14, textSecondary)
       │    XP进度条 + "3,420 / 5,000 XP"
       ├─ 犒赏点模块 (与等级卡片同款)
       │    🪙 图标 + 余额数字(fontSize:24, fontWeight:600)
       │    "奖励商店" 文字按钮 →
       ├─ 连续活跃卡片
       │    🔥 火焰 + 天数(fontSize:20) + "连续活跃"
       ├─ 重点领域信息卡片
       │    领域名称 + 领域图标
       │    "每周可投入 N 小时"
       ├─ 统计数据网格 (2×2)
       │    ├─ 已完成任务数
       │    ├─ 累计专注时长
       │    ├─ 已完成目标数
       │    └─ 当前等级
       └─ 设置列表项 (已有SettingsPage承接)
```

### 4.3 关键数值

| 元素 | 字号 | 字重 | 颜色 |
|-----|-----|-----|-----|
| 等级数字 | 32pt | 700 | primary |
| 称号 | 14pt | 400 | textSecondary |
| XP数字 | 13pt | 500 | onSurface |
| 犒赏点余额 | 24pt | 600 | secondaryOrange |
| 连续天数 | 20pt | 600 | secondaryOrange |
| 统计项数值 | 20pt | 600 | onSurface |
| 统计项标签 | 12pt | 400 | textSecondary |
| 卡片圆角 | 32pt（顶部大卡）/ 12pt（信息卡）|
| 页面水平内边距 | 16pt |

### 4.4 组件清单

- `LevelBadgeCard`（已有，重构）：展示等级+称号+XP进度
- `PraisePointsCard`（新建）：犒赏点余额展示
- `StreakCard`（新建）：连续活跃天数
- `FocusedDomainCard`（新建）：重点领域+可投入时间
- `StatsGrid`（已有，重构）：统计数据2×2网格

### 4.5 交互边界

- **个人页不扩成设置后台全集**：仅展示成长状态和必要档案
- **设置页独立为 SettingsPage**：不混在个人主导航页内
- **奖励商店入口在个人页**：犒赏点余额旁放置快捷入口

---

## 5. 页面层级总览

```
主导航（BottomNavigationBar，4 Tab）
│
├─ Tab0: 首页 Dashboard
│    └─ GoalDetailPage → ProjectDetailPage → TodoDetailPage
│
├─ Tab1: 目标 Goal
│    └─ GoalDetailPage
│         └─ ProjectDetailPage → TodoDetailPage
│
├─ Tab2: 项目 Project
│    └─ ProjectDetailPage
│         └─ TodoDetailPage
│
└─ Tab3: 个人 Profile
     └─ SettingsPage

跨Tab浮动：
  ├─ AddGoalPage（目标Tab内或FAB触发）
  ├─ AddProjectPage（项目Tab内或FAB触发）
  ├─ AddTodoPage（项目详情内触发）
  ├─ DailyReviewPage（首页复盘按钮触发）
  └─ RewardShopPage（个人页快捷入口触发）
```

---

## 6. 领域页（Domain）定位说明

> 依蓝图第13.5条：**领域页若需要提及，只能作为次级页/观察视角，不得替代主导航项目页**

- **DomainDetailPage** 保留为 `GoalDetailPage` 内的次级跳转
- 主导航不设独立"领域"Tab
- 用户可通过目标详情内的"领域标签"进入领域视角
- 领域页不承载执行主职责

---

## 7. 通用设计规范（Flutter实现参考）

### 7.1 色彩系统（已有 design_tokens.dart）

```
主色: primaryColor = #4F46E5 (Indigo-600)
辅助紫: secondaryPurple = #A855F7
辅助橙: secondaryOrange = #F97316
成功: successColor = #4CAF50
危险: errorColor = #F44336
亮色背景: backgroundLight = #FAFAFA
暗色背景: backgroundDark = #0F172A
```

### 7.2 字号规范

```
Display: 57/45/36pt（首页大数字展示用）
Headline: 32/28/24pt（页面标题）
Title: 22/16/14pt（卡片标题）
Body: 16/14/12pt（正文内容）
Label: 14/12/11pt（标签、小字）
```

### 7.3 间距网格（4pt基准）

```
spacing0=0, spacing1=4, spacing2=8, spacing3=12
spacing4=16, spacing5=20, spacing6=24, spacing8=32
```

### 7.4 圆角规范

```
radiusSmall=4, radiusMedium=8, radiusLarge=12
radiusXLarge=32（卡片）, radiusRound=999（标签/头像）
```

### 7.5 阴影（iOS风格）

```
shadowIOS: blur20, offset(0,8), spread:-5, opacity:0.05
shadowSmall: blur4, offset(0,2)
shadowMedium: blur8, offset(0,4)
```

### 7.6 动画规范

```
durationNormal = 300ms
curveDefault = Curves.easeInOut
页面切换: PageView.animateToPage(duration:300ms)
```

---

## 8. 组件清单汇总

| 组件名 | 类型 | 用途 | 状态 |
|-------|-----|-----|-----|
| `GoalSummaryCard` | 新建 | 首页主目标卡片 | ⬜ 待开发 |
| `ProjectBannerCard` | 新建 | 首页当前项目横幅 | ⬜ 待开发 |
| `GrowthSummaryBar` | 新建 | 首页XP/等级/犒赏点摘要 | ⬜ 待开发 |
| `MainGoalHeroCard` | 新建 | 目标页置顶主目标大卡 | ⬜ 待开发 |
| `Goal关联ProjectChip` | 新建 | 目标→关联项目数展示 | ⬜ 待开发 |
| `ProjectGridCard` | 新建 | 项目页网格卡片 | ⬜ 待开发 |
| `ProjectProgressBar` | 新建 | 统一项目进度条组件 | ⬜ 待开发 |
| `PraisePointsCard` | 新建 | 个人页犒赏点模块 | ⬜ 待开发 |
| `StreakCard` | 新建 | 个人页连续活跃模块 | ⬜ 待开发 |
| `FocusedDomainCard` | 新建 | 个人页重点领域模块 | ⬜ 待开发 |
| `TodoListItem` | 已有 | 今日事项列表项 | 🔵 需增加参数 |
| `GoalListCard` | 已有 | 目标列表卡片 | 🔵 需改造 |
| `ProjectStatusBadge` | 已有 | 项目状态标签 | ✅ 可直接复用 |
| `LevelBadgeCard` | 已有 | 等级XP卡片 | 🔵 需重构 |
| `StatsGrid` | 已有 | 统计数据网格 | 🔵 需重构 |

---

## 9. 前端注意事项

1. **BottomNavigationBar 高度约80pt**：首页底部需预留 `SliverPadding(bottom:80)` 防止内容被遮挡
2. **首页 `PageView` 已配置 `physics: NeverScrollableScrollPhysics()`**：切换由 BottomNav 控制，不允许手势滑动
3. **进度计算逻辑在后端**（Blueprint 第14章规则）：前端负责展示，项目进度=事项完成率，目标进度=项目内事项完成率汇总
4. **目标页与项目页职责严格分离**：目标页不直接展示事项列表，事项操作在项目详情内完成
5. **暗色模式**：所有颜色使用 `DesignTokens` 而非硬编码 HEX，保证亮/暗主题自动适配
6. **新建页面需注册路由**：参考 `lib/routes/` 现有路由配置方式

---

## 10. Figma 输出计划

| 优先级 | 页面 | 交付物 |
|-------|-----|-------|
| P0 | 首页 Dashboard | 低保真线框稿（确认模块位置） |
| P0 | 目标页 Goal | 低保真线框稿 |
| P0 | 项目页 Project | 低保真线框稿 |
| P0 | 个人页 Profile | 低保真线框稿 |
| P1 | 各详情页（GoalDetail/ProjectDetail）| 中保真 |

> 当前优先交付四主导航页的低保真结构稿，确认后再进高保真。
> Figma 账号由用户提供后创建Praxis设计文件。
