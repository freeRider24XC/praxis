# Praxis Backend Setup

这份文档用于把当前 Flutter 客户端接到真实线上环境。你已经有自己的云服务器时，最短路径如下：

## 1. 架构约定

- Auth / 主数据：Supabase
- 客户端本地缓存：Hive
- 托管 AI：部署在你自己的服务器上
- Flutter 运行时通过 `--dart-define` 注入环境变量

仓库内已经提供了可直接复用的部署资产：

- [deploy/README.md](/Users/tankangping/Documents/project/praxis/deploy/README.md)
- [deploy/staging/docker-compose.yml](/Users/tankangping/Documents/project/praxis/deploy/staging/docker-compose.yml)
- [deploy/staging/nginx/default.conf](/Users/tankangping/Documents/project/praxis/deploy/staging/nginx/default.conf)
- [scripts/build_web_staging.sh](/Users/tankangping/Documents/project/praxis/scripts/build_web_staging.sh)
- [scripts/deploy_staging_compose.sh](/Users/tankangping/Documents/project/praxis/scripts/deploy_staging_compose.sh)

## 2. 客户端所需环境变量

运行 Web 或移动端时，至少支持以下变量：

```bash
--dart-define=PRAXIS_STAGE=staging
--dart-define=PRAXIS_SUPABASE_URL=https://your-project.supabase.co
--dart-define=PRAXIS_SUPABASE_ANON_KEY=your-supabase-publishable-key
--dart-define=PRAXIS_AI_API_BASE_URL=https://your-domain.com/praxis-ai
--dart-define=PRAXIS_AI_API_TOKEN=optional-shared-token
--dart-define=PRAXIS_REQUIRE_CLOUD_AUTH=true
```

## 3. Supabase 初始化顺序

1. 创建 Supabase project
2. 执行 `supabase/migrations/20260604_praxis_launch_v1.sql`
3. 在 Authentication 中启用 `Email OTP / Magic Link`
4. 将站点 URL 和 redirect URL 配成你的 Web 域名与移动端 scheme
5. 把 publishable key 和 URL 注入客户端

## 4. 托管 AI 服务职责

建议部署成一个独立服务，例如：

- `POST /praxis-ai/plan-goal`
- `POST /praxis-ai/review-day`
- `POST /praxis-ai/suggest-today`

仓库里已经提供了一个最小可运行实现：

- [server/managed-ai/README.md](/Users/tankangping/Documents/project/praxis/server/managed-ai/README.md)
- [server/managed-ai/src/index.js](/Users/tankangping/Documents/project/praxis/server/managed-ai/src/index.js)

服务端负责：

- 持有真正的模型密钥
- 请求限流
- 成本日志
- 异常兜底
- 输出严格 JSON

### OpenAI 兼容提供方示例

当前仓库内置的托管 AI 服务并不绑定单一厂商，只要目标平台兼容 OpenAI `chat/completions` 即可。

例如 MiniMax 官方文档当前给出的兼容基地址是：

```text
https://api.minimax.io/v1
```

一组可直接套用的环境变量如下：

```bash
OPENAI_PROVIDER_NAME=MiniMax
OPENAI_BASE_URL=https://api.minimax.io/v1
OPENAI_MODEL=MiniMax-M2.7-highspeed
OPENAI_API_KEY=your-minimax-key
```

如果你使用的是 MiniMax 官方 Anthropic 兼容入口，则改成：

```bash
OPENAI_PROVIDER_NAME=MiniMax
OPENAI_API_PROTOCOL=anthropic
OPENAI_BASE_URL=https://api.minimaxi.com/anthropic
OPENAI_MODEL=MiniMax-M2.7
OPENAI_API_KEY=your-minimax-key
```

如果 `GET /praxis-ai/health` 中 `managedAiConfigured` 为 `false`，说明服务还处在 mock 模式。

## 5. 推荐部署形态

### Web

- 直接发布 Flutter Web 构建产物
- 域名例如 `app.yourdomain.com`
- 托管可以是 Nginx / Cloudflare Pages / Vercel / S3 + CDN

### 托管 AI API

- 你的云服务器上部署 Node / Python 服务均可
- 域名例如 `api.yourdomain.com`
- 建议走 HTTPS
- 如果直接使用仓库自带实现，最简单是：
  - `docker build -t praxis-managed-ai server/managed-ai`
  - 用 Nginx 把 `/praxis-ai/*` 反代到容器 `8787`

### 移动端

- Android Beta 先连接 `staging`
- iOS 等 staging 稳定后再补正式签名与上架

## 6. 首轮上线建议

先做一套 `staging`：

- `Supabase staging project`
- `staging Web URL`
- `staging AI API`

当完整闭环跑通后，再复制到 `prod`。

### staging 最短命令

```bash
cp deploy/staging/.env.example deploy/staging/.env
# 修改 deploy/staging/.env
bash scripts/deploy_staging_compose.sh
```

部署完成后：

- `https://your-domain.com/` -> 公开体验页
- `https://your-domain.com/app/` -> Flutter Web App
- `https://your-domain.com/praxis-ai/health` -> 托管 AI 健康检查

## 7. 最小 Nginx 反向代理示例

```nginx
location /praxis-ai/ {
  proxy_pass http://127.0.0.1:8787/;
  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```
