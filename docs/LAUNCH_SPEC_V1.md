# Praxis Launch Spec v1

## 目标

定义首个“可以分享给别人体验”的正式版本边界，避免继续以历史页面数量替代产品完成度。

## 首版产品边界

- 平台：Web 优先，Android 并行，iOS 作为发布准备项
- 用户：以个人成长闭环用户为核心，不做社区产品
- 数据：云端主存储，本地缓存
- AI：平台统一托管，客户端保留 mock fallback 作为开发/异常降级

## 必做主链

1. Intent 输入
2. 重点领域确认
3. 每周容量确认
4. AI 规划草稿
5. Goal / Project / Todo 落库
6. 本周编排
7. 今日执行
8. XP + 犒赏点反馈
9. 奖励兑换与奖励待办
10. 每日复盘与明日重点

## 核心对象

- `UserProfile`
  - 保留 `focusedDomainId`
  - 保留 `weeklyCapacityHours`
  - 保留 `streakDays`
  - 新增 `remoteUserId`
  - 预留 `rewardPreferenceSummary`
- `TodoScheduleSlot`
  - `todoId`
  - `scheduledDate`
  - `scheduledStart`
  - `scheduledEnd`
  - `status`
  - `source`
- `PraisePointLedger`
  - 奖励产出/消费流水
- `RewardTemplate`
  - 奖励商店模板定义
- `RewardRedemption`
  - 奖励兑换记录
- `RewardTodo`
  - 奖励兑现动作

## 运行时架构

- 客户端：Flutter
- Auth / 数据主存储：Supabase
- 本地缓存：Hive
- AI：托管 HTTP API
- 环境：`local / staging / prod`

## 验收标准

- `fvm flutter test` 通过
- `fvm flutter build web` 通过
- 新用户能从 Onboarding 走到 AI 规划并落库
- 首页能看到今天事项、本周编排、奖励兑现入口、复盘入口
- 完成 Todo 会产生 XP 与犒赏点
- 兑换奖励会生成奖励待办
- 完成 Daily Review 会保存明日重点
