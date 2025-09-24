#!/usr/bin/env python3
"""开发环境启动脚本"""
import os
import sys
import subprocess
from pathlib import Path

# 添加项目根目录到 Python 路径
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

def run_command(cmd: str, cwd: Path = None):
    """运行命令"""
    print(f"执行: {cmd}")
    result = subprocess.run(cmd, shell=True, cwd=cwd or project_root)
    if result.returncode != 0:
        print(f"命令执行失败: {cmd}")
        sys.exit(1)

def setup_env():
    """设置开发环境"""
    env_file = project_root / ".env"
    env_example = project_root / "env.example"
    
    if not env_file.exists() and env_example.exists():
        print("复制环境变量配置文件...")
        run_command(f"copy {env_example} {env_file}")

def install_dependencies():
    """安装依赖"""
    print("安装 Python 依赖...")
    run_command("pip install -r requirements.txt")

def run_migrations():
    """运行数据库迁移"""
    print("运行数据库迁移...")
    run_command("alembic upgrade head")

def start_dev_server():
    """启动开发服务器"""
    print("启动开发服务器...")
    run_command("python main.py")

def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description="PlantVision API 开发工具")
    parser.add_argument("command", choices=[
        "setup", "install", "migrate", "run", "dev"
    ], help="要执行的命令")
    
    args = parser.parse_args()
    
    if args.command == "setup":
        setup_env()
    elif args.command == "install":
        install_dependencies()
    elif args.command == "migrate":
        run_migrations()
    elif args.command == "run":
        start_dev_server()
    elif args.command == "dev":
        # 完整的开发环境设置
        setup_env()
        install_dependencies()
        run_migrations()
        start_dev_server()

if __name__ == "__main__":
    main()






