# Praxis Managed AI Server

这是 Praxis 面向真实用户的托管 AI 最小服务端。

## 功能

- `POST /plan-goal`
- `POST /review-day`
- `POST /suggest-today`
- 无模型密钥时自动回退到 mock，方便先打通 staging
- 可通过共享 token 做最小鉴权
- 支持任意 OpenAI 兼容模型提供方，例如 OpenAI、MiniMax

## 运行

```bash
cd server/managed-ai
cp .env.example .env
node src/index.js
```

或：

```bash
npm start
```

## 环境变量

- `PORT`
- `PRAXIS_AI_SHARED_TOKEN`
- `OPENAI_API_KEY`
- `OPENAI_PROVIDER_NAME`
- `OPENAI_API_PROTOCOL`
- `OPENAI_BASE_URL`
- `OPENAI_MODEL`
- `OPENAI_TIMEOUT_MS`

### MiniMax 示例

根据 MiniMax 官方 OpenAI 兼容文档，使用方式如下：

```bash
OPENAI_PROVIDER_NAME=MiniMax
OPENAI_BASE_URL=https://api.minimax.io/v1
OPENAI_MODEL=MiniMax-M2.7-highspeed
OPENAI_API_KEY=your-minimax-key
```

如果配置正确，`GET /health` 会返回类似：

```json
{
  "ok": true,
  "managedAiConfigured": true,
  "provider": "MiniMax",
  "protocol": "openai",
  "baseUrl": "https://api.minimax.io/v1",
  "model": "MiniMax-M2.7-highspeed"
}
```

### MiniMax Anthropic 兼容示例

如果你使用的是 MiniMax 官方 `Anthropic` 兼容入口：

```bash
OPENAI_PROVIDER_NAME=MiniMax
OPENAI_API_PROTOCOL=anthropic
OPENAI_BASE_URL=https://api.minimaxi.com/anthropic
OPENAI_MODEL=MiniMax-M2.7
OPENAI_API_KEY=your-minimax-key
```

服务端会自动请求 `POST /v1/messages`，并把返回的文本块解析成严格 JSON。

## 与 Flutter 对接

客户端需要：

```bash
--dart-define=PRAXIS_AI_API_BASE_URL=https://your-domain.com/praxis-ai
--dart-define=PRAXIS_AI_API_TOKEN=your-shared-token
```

如果你把这个服务挂在 `https://your-domain.com/praxis-ai` 反向代理后面，Flutter 会自动请求：

- `/plan-goal`
- `/review-day`
- `/suggest-today`
