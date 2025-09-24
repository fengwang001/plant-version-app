# PlantVision API

PlantVision AI 植物识别与社区平台后端 API 服务。

## 技术栈

- **框架**: FastAPI 0.104+
- **数据库**: PostgreSQL 15+ 
- **缓存**: Redis 7+
- **任务队列**: Celery + Redis
- **认证**: JWT + OAuth2
- **文件存储**: AWS S3 兼容
- **AI 服务**: Plant.id + Replicate
- **支付**: RevenueCat + Apple IAP + Google Play

## 项目结构

```
python/
├── app/                    # 应用程序代码
│   ├── api/               # API 路由
│   │   └── api_v1/        # API v1 版本
│   │       └── endpoints/ # API 端点
│   ├── core/              # 核心配置
│   ├── db/                # 数据库配置
│   ├── models/            # 数据模型
│   ├── schemas/           # Pydantic 模式
│   ├── services/          # 业务逻辑服务
│   ├── tasks/             # Celery 任务
│   └── utils/             # 工具函数
├── tests/                 # 测试代码
├── alembic/               # 数据库迁移
├── logs/                  # 日志文件
├── certs/                 # 证书文件
├── scripts/               # 脚本工具
├── requirements.txt       # Python 依赖
├── env.example           # 环境变量示例
├── Dockerfile            # Docker 镜像
├── docker-compose.yml    # Docker 编排
└── main.py              # 应用入口
```

## 快速开始

### 1. 环境准备

```bash
# 克隆项目
git clone <repository-url>
cd flutter_application_1/python

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate     # Windows

# 安装依赖
pip install -r requirements.txt
```

### 2. 环境配置

```bash
# 复制环境变量配置
cp env.example .env

# 编辑 .env 文件，配置数据库、Redis、API 密钥等
```

### 3. 数据库设置

```bash
# 启动 PostgreSQL 和 Redis (使用 Docker)
docker-compose up -d db redis

# 运行数据库迁移
alembic upgrade head
```

### 4. 启动服务

```bash
# 开发模式启动
python main.py

# 或使用 uvicorn
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### 5. 启动后台任务 (可选)

```bash
# 启动 Celery Worker
celery -A app.tasks.celery_app worker --loglevel=info

# 启动 Celery Beat (定时任务)
celery -A app.tasks.celery_app beat --loglevel=info

# 启动 Flower (任务监控)
celery -A app.tasks.celery_app flower --port=5555
```

## Docker 部署

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f api
```

## API 文档

启动服务后访问：

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/api/v1/openapi.json

## 主要功能模块

### 认证模块 (`/api/v1/auth`)

- `POST /auth/register` - 邮箱注册
- `POST /auth/login` - 邮箱登录
- `POST /auth/login/apple` - Apple Sign In
- `POST /auth/login/google` - Google Sign In
- `POST /auth/login/guest` - 游客登录
- `POST /auth/refresh` - 刷新令牌
- `POST /auth/logout` - 退出登录

### 植物模块 (`/api/v1/plants`)

- `POST /plants/identify` - 植物识别
- `GET /plants/identifications` - 识别历史
- `GET /plants/identifications/{id}` - 识别详情
- `DELETE /plants/identifications/{id}` - 删除识别
- `GET /plants/{id}` - 植物详情
- `GET /plants/` - 植物列表
- `GET /plants/search` - 植物搜索

### 媒体模块 (`/api/v1/media`)

- `POST /media/presign` - 获取上传签名
- `POST /media/confirm` - 确认上传完成
- `GET /media/{id}` - 媒体文件信息

### 用户模块 (`/api/v1/users`)

- `GET /users/me` - 当前用户信息
- `PUT /users/me` - 更新用户信息
- `GET /users/me/stats` - 用户统计

### 订阅模块 (`/api/v1/subscriptions`)

- `GET /subscriptions/me` - 当前订阅
- `POST /subscriptions/iap/validate` - IAP 票据验证
- `GET /credits/me` - 积分余额
- `POST /credits/consume` - 消费积分

## 开发指南

### 代码规范

- 使用 Black 进行代码格式化
- 使用 isort 进行导入排序
- 使用 flake8 进行代码检查
- 遵循 PEP 8 代码规范

```bash
# 格式化代码
black .
isort .

# 代码检查
flake8 .
```

### 测试

```bash
# 运行所有测试
pytest

# 运行特定测试
pytest tests/api/test_auth.py

# 生成覆盖率报告
pytest --cov=app tests/
```

### 数据库迁移

```bash
# 创建新的迁移
alembic revision --autogenerate -m "描述信息"

# 应用迁移
alembic upgrade head

# 回滚迁移
alembic downgrade -1
```

## 部署指南

### 生产环境配置

1. 设置环境变量
2. 配置 HTTPS
3. 设置反向代理 (Nginx)
4. 配置监控和日志
5. 设置自动备份

### 监控和日志

- 应用日志: `logs/app.log`
- 错误日志: `logs/error.log` 
- Celery 日志: `logs/celery.log`
- Flower 监控: http://localhost:5555

## 许可证

MIT License

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request
