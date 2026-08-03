# Deploy Assets

这个目录存放 Praxis 的服务器部署样板。

## 结构

- `staging/.env.example`
  - staging 所需环境变量模板
- `staging/docker-compose.yml`
  - Flutter Web + Managed AI 的最小 compose
- `staging/nginx/default.conf`
  - Web 静态托管 + `/praxis-ai/` 反代样板
- `systemd/praxis-managed-ai.service.example`
  - 如果你不用 Docker，可直接用 systemd 跑托管 AI

## 推荐顺序

1. 本地执行 `fvm flutter build web`
2. 执行 `bash scripts/package_public_site.sh`
3. 复制 `staging/.env.example` 为 `.env`
4. 修改域名、Supabase、AI token
5. 在服务器或本地运行 `docker compose up -d`

## 公开站点结构

- `/`
  - 公开预览 landing page
- `/app/`
  - Flutter Web 应用
- `/praxis-ai/`
  - 托管 AI API 反代入口
