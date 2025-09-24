#!/usr/bin/env python3
"""测试服务器启动脚本"""
import os
import sys
from pathlib import Path

# 添加项目根目录到 Python 路径
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

# 设置环境变量（用于测试）
os.environ.setdefault("SECRET_KEY", "test-secret-key-change-in-production")
os.environ.setdefault("JWT_SECRET_KEY", "test-jwt-secret-key-change-in-production")
os.environ.setdefault("DATABASE_URL", "mysql+aiomysql://root:root@localhost:3306/plant_ai?charset=utf8mb4")
os.environ.setdefault("DATABASE_URL_SYNC", "mysql+pymysql://root:root@localhost:3306/plant_ai?charset=utf8mb4")
os.environ.setdefault("REDIS_URL", "redis://localhost:6379/0")
os.environ.setdefault("DEBUG", "true")

if __name__ == "__main__":
    try:
        import uvicorn
        from app.main import app
        
        print("🚀 启动 PlantVision API 测试服务器...")
        print("📋 API 文档: http://localhost:8000/docs")
        print("🔍 健康检查: http://localhost:8000/health")
        print("📊 应用信息: http://localhost:8000/")
        print()
        
        uvicorn.run(
            app,
            host="0.0.0.0",
            port=8000,
            reload=True,
            log_level="info",
        )
        
    except ImportError as e:
        print(f"❌ 导入错误: {e}")
        print("💡 请先安装依赖: pip install -r requirements.txt")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 启动失败: {e}")
        sys.exit(1)
