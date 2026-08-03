# Praxis 蓝图差异审计

基线文档：[PRODUCT_BLUEPRINT_V1.md](/Users/tankangping/Documents/project/praxis/docs/PRODUCT_BLUEPRINT_V1.md)

## 目的

这份文档只回答一个问题：

当前实现距离最新产品蓝图还差什么，下一步应该先改哪一层。

---

## A. 本轮已对齐

### 1. 核心结构开始收紧到 `Goal -> Project -> Todo`

本轮已把数据服务改成以下规则优先：

- `Project` 默认只保留一个主目标
- `Todo` 优先通过 `projectId` 归属到目标
- `Goal` 进度按其项目集合汇总
- `Project` 进度按其事项完成情况计算

对应实现：

- [database_service.dart](/Users/tankangping/Documents/project/praxis/lib/common/services/database_service.dart)
- [ai_plan_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/ai_chat/ai_plan_page.dart)
- [add_project_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/project/add_project_page.dart)
- [add_todo_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/todo/add_todo_page.dart)

### 2. 旧结构数据开始自动归一化

为了兼容历史数据，本轮增加了自动收拢逻辑：

- 多目标项目会被收紧到单主目标
- 未挂项目的旧 Todo 会被自动收纳到系统项目
- Goal / Project / Todo 的回链关系会在初始化时归整

这一步是为了让后续页面重构不再继续建立在旧数据关系上。

---

## B. 当前仍未对齐

### 1. 首次链路仍未完全符合蓝图

蓝图要求：

`意图输入 -> 系统推断领域 -> 用户确认 -> Goal/Project 草稿 -> Todo 草稿`

当前状态：

- [onboarding_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/onboarding/onboarding_page.dart)
  - 已改成先输入主线，再由系统推断领域并让用户确认
- [ai_plan_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/ai_chat/ai_plan_page.dart)
  - 已拆成“领域确认 -> 目标草稿 -> 当前推进项目 -> 里程碑 -> Todo 草稿”
  - 但仍缺少更强的编辑能力，目前仍偏“确认草稿”而非“逐段精修”

### 2. 首页还没完全变成蓝图要求的三层主结构

蓝图要求首页同时表达：

1. 当前主目标
2. 当前推进项目
3. 今日事项

当前状态：

- [dashboard_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/dashboard/dashboard_page.dart)
  - 顶部已经改成统一的决策板，集中表达 `当前主目标 -> 当前推进项目 -> 今天这一件事`
  - 编排 / 复盘 / 奖励文案也已改成围绕当前项目服务
  - 但中下部仍保留较多“功能卡片并列”形态，离彻底的日决策台还有一段距离

### 3. 领域仍然偏强入口，而不是观察视角

蓝图定义：

- `Domain` 是归属维度和观察视角
- 不是首次进入的主阻塞步骤
- 也不是执行链路主容器

当前状态：

- [main_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/main/main_page.dart)
  - 领域仍然作为顶层导航主 tab
- [domain_detail_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/life_domains/domain_detail_page.dart)
  - 已改成“领域视角”而不是“领域工作台”
  - 但顶层导航层面，领域仍然偏强入口

### 4. 愿景层 `Vision` 还未进入正式结构

蓝图已定义：

`Vision -> Goal -> Project -> Todo`

当前状态：

- 代码层仍未引入 `Vision` 对象
- 但蓝图同时明确：`Vision` 不进入 MVP 首次流程

因此这里的策略应是：

- 先补模型与保留位
- 不把它塞进首次体验

### 5. 编排层仍然是最小实现，不是完整蓝图形态

当前已有：

- `TodoScheduleSlot`
- `ScheduleService`
- 今日/本周编排入口

仍缺：

- 时间画像采集与使用
- 身份类型 / 偏好时段驱动的任务安排
- 任务拆小 / 压缩 / 延后建议

### 6. 奖励层已落对象，但规则还没完全按蓝图细化

当前已有：

- `PraisePointLedger`
- `RewardTemplate`
- `RewardRedemption`
- `RewardTodo`

仍缺：

- 重要度 / 优先级 / 难度 的事项加权规则
- 奖励恢复体验的表达
- 奖励效果回顾进入复盘

### 7. 创建链路已经开始对齐，但仍缺少完整的串联引导

当前状态：

- [add_goal_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/goal/add_goal_page.dart)
  - 已开始按“先定目标，项目和事项后续再拆”的心智组织
- [add_project_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/project/add_project_page.dart)
  - 已明确项目是目标的推进容器
- [add_todo_page.dart](/Users/tankangping/Documents/project/praxis/lib/pages/todo/add_todo_page.dart)
  - 已明确事项必须先挂项目，目标自动继承

仍缺：

- 创建完成后的连续引导还不够强
- 首次链路里还不能顺手精修 AI 草稿结构
- 旧入口仍然较多，用户容易走进非主推荐路径

---

## C. 下一步执行顺序

### 第一优先级：主链路重构

1. 补强 AI Plan 的可编辑确认能力
2. 继续把 Dashboard 压成更完整的日决策台
3. 串起创建完成后的连续引导，让用户自然进入执行

### 第二优先级：领域降权

1. 调整顶层导航或入口权重
2. 避免领域与目标 / 项目抢主组织权

### 第三优先级：补轻量时间画像

1. identityType
2. weekday/weekend available hours
3. preferred work time
4. max focus block

### 第四优先级：奖励与复盘深化

1. 奖励规则细化
2. 复盘输出固定为
   - 今天发生了什么
   - 明天最重要的一步
   - 是否需要调整当前项目节奏

### 第五优先级：首个可分享体验审计

1. 从首次进入走一遍完整链路
2. 找出所有仍然暴露旧 MVP 结构的入口
3. 明确 staging 还缺哪些“外部试用时会卡住”的问题

---

## D. 当前判断

当前仓库已经不是“旧版通用 Todo App”，但也还不能说“已经按最新蓝图重构完成”。

更准确的状态是：

> 已完成线上化和部分闭环能力搭底，但产品主结构仍处于“蓝图重构进行中”。
