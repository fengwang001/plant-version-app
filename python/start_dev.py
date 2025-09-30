#!/usr/bin/env python3
"""开发环境启动脚本"""
import os
import sys
import subprocess
import time
from pathlib import Path

def set_env_vars():
    """设置开发环境变量"""
    env_vars = {
        "SECRET_KEY": "dev-secret-key-change-in-production",
        "JWT_SECRET_KEY": "dev-jwt-secret-key-change-in-production",
        "DATABASE_URL": "mysql+aiomysql://root:root@localhost:3306/j2eedb?charset=utf8mb4",
        "DATABASE_URL_SYNC": "mysql+pymysql://root:root@localhost:3306/j2eedb?charset=utf8mb4",
        "REDIS_URL": "redis://localhost:6379/0",
        "CELERY_BROKER_URL": "redis://localhost:6379/1",
        "CELERY_RESULT_BACKEND": "redis://localhost:6379/2",
        "DEBUG": "true",
        "APP_NAME": "PlantVision API",
        "APP_VERSION": "1.0.0",
    }
    
    for key, value in env_vars.items():
        os.environ[key] = value
    
    print("✅ 环境变量已设置")

def check_dependencies():
    """检查依赖服务"""
    print("🔍 检查依赖服务...")
    
    # 检查 MySQL
    try:
        import pymysql
        conn = pymysql.connect(
            host='localhost',
            port=3306,
            user='root',
            password='root',
            database='j2eedb',
            charset='utf8mb4'
        )
        conn.close()
        print("✅ MySQL 连接正常")
    except Exception as e:
        print(f"❌ MySQL 连接失败: {e}")
        print("请确保 MySQL 服务已启动并创建了 j2eedb 数据库")
        return False
    
    # 检查 Redis
    try:
        import redis
        r = redis.Redis(host='localhost', port=6379, db=0)
        r.ping()
        print("✅ Redis 连接正常")
    except Exception as e:
        print(f"❌ Redis 连接失败: {e}")
        print("请确保 Redis 服务已启动")
        return False
    
    return True

def run_migrations():
    """运行数据库迁移"""
    print("🔄 运行数据库迁移...")
    try:
        result = subprocess.run(
            ["alembic", "upgrade", "head"],
            capture_output=True,
            text=True,
            check=True
        )
        print("✅ 数据库迁移完成")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ 数据库迁移失败: {e}")
        print(f"输出: {e.stdout}")
        print(f"错误: {e.stderr}")
        return False

def start_services():
    """启动开发服务"""
    print("🚀 启动 FastAPI 开发服务器...")
    
    try:
        # 启动 FastAPI 服务器
        subprocess.run([
            "uvicorn",
            "app.main:app",
            "--host", "0.0.0.0",
            "--port", "8000",
            "--reload",
            "--log-level", "info"
        ], check=True)
    except KeyboardInterrupt:
        print("\n👋 服务已停止")
    except Exception as e:
        print(f"❌ 服务启动失败: {e}")

def main():
    """主函数"""
    print("🌱 PlantVision 后端开发环境启动")
    print("=" * 50)
    
    # 设置环境变量
    set_env_vars()
    
    # 检查依赖
    if not check_dependencies():
        print("❌ 依赖检查失败，请修复后重试")
        sys.exit(1)
    
    # 运行迁移
    if not run_migrations():
        print("❌ 数据库迁移失败，请检查数据库连接")
        sys.exit(1)
    
    # 启动服务
    start_services()

if __name__ == "__main__":
    main()








