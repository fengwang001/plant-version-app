"""Celery 应用配置"""
from celery import Celery
from ..core.config import get_settings

settings = get_settings()

# 创建 Celery 实例
celery_app = Celery(
    "plantvision",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=[
        "app.tasks.plant_tasks",
        "app.tasks.video_tasks",
        "app.tasks.notification_tasks",
    ]
)

# Celery 配置
celery_app.conf.update(
    # 时区配置
    timezone="UTC",
    enable_utc=True,
    
    # 任务序列化
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    
    # 结果过期时间（秒）
    result_expires=3600,
    
    # 任务路由
    task_routes={
        "app.tasks.plant_tasks.*": {"queue": "plant_queue"},
        "app.tasks.video_tasks.*": {"queue": "video_queue"},
        "app.tasks.notification_tasks.*": {"queue": "notification_queue"},
    },
    
    # 任务重试配置
    task_acks_late=True,
    worker_prefetch_multiplier=1,
    
    # 定时任务配置
    beat_schedule={
        "cleanup-expired-media": {
            "task": "app.tasks.plant_tasks.cleanup_expired_media",
            "schedule": 3600.0,  # 每小时执行一次
        },
        "update-plant-statistics": {
            "task": "app.tasks.plant_tasks.update_plant_statistics",
            "schedule": 86400.0,  # 每天执行一次
        },
    },
)

# 自动发现任务
celery_app.autodiscover_tasks()
