# Praxis AI API Contract

当前 Flutter 客户端已经支持托管 AI 模式。服务端只需要遵守下面的 HTTP 契约。

## Base URL

客户端读取：

```text
PRAXIS_AI_API_BASE_URL
```

如果配置为：

```text
https://api.example.com/praxis-ai
```

那么客户端会请求：

- `POST /plan-goal`
- `POST /review-day`
- `POST /suggest-today`

仓库中的最小服务端实现默认还提供：

- `GET /health`

`GET /health` 响应示例：

```json
{
  "ok": true,
  "managedAiConfigured": true,
  "provider": "MiniMax",
  "protocol": "anthropic",
  "baseUrl": "https://api.minimax.io/v1",
  "model": "MiniMax-M2.7-highspeed"
}
```

## 1. Plan Goal

### Request

```json
{
  "goalText": "三个月内完成一个可上线作品",
  "focusedDomainId": "domain-id",
  "weeklyCapacityHours": 6
}
```

### Response

必须返回严格 JSON 对象：

```json
{
  "domain": "职业发展",
  "goal": {
    "title": "完成可上线作品",
    "description": "三个月内完成一个可公开分享的作品",
    "targetDate": "2026-09-30"
  },
  "milestones": ["明确需求", "完成 MVP", "发布分享"],
  "project": {
    "name": "作品上线项目",
    "description": "围绕上线目标的第一轮执行项目"
  },
  "todos": [
    {
      "title": "列出首版必须完成的 3 个用户流程",
      "description": "先收敛第一轮范围",
      "dueDate": "2026-06-10",
      "priority": "high"
    }
  ],
  "followUpQuestions": ["你本周最稳定的可投入时间段是什么？"]
}
```

## 2. Review Day

### Request

```json
{
  "whatDone": "今天完成了首页改造",
  "blockers": "登录流还没有接真服务",
  "topPriorityTomorrow": "把 staging 接起来"
}
```

### Response

```json
{
  "summary": "今天已经把关键主链往前推进了一步。",
  "focus": "明天先把 staging 登录和数据链路接通。"
}
```

## 3. Suggest Today

### Request

```json
{
  "focusedDomain": "职业发展",
  "todos": [
    {
      "title": "完成 staging 配置",
      "description": "接入真实环境",
      "priority": "high",
      "dueDate": "2026-06-06T00:00:00.000"
    }
  ]
}
```

### Response

```json
{
  "suggestion": "今天先把 staging 配好，这会直接带动主线往前。"
}
```

## 4. 错误约定

- 2xx：客户端按成功解析
- 非 2xx：客户端自动回退到本地 provider 或 mock fallback
- 响应必须是 UTF-8 JSON

## 5. 鉴权

如果你想在服务端加一个简单共享 token，客户端会自动带：

```text
Authorization: Bearer <PRAXIS_AI_API_TOKEN>
```
