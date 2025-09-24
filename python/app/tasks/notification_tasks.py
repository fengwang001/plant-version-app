"""通知相关异步任务"""
import asyncio
from typing import Dict, Any, List
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from .celery_app import celery_app
from ..core.config import get_settings
from ..services.user_service import UserService

settings = get_settings()

# 创建异步数据库引擎
async_engine = create_async_engine(settings.DATABASE_URL, echo=settings.DEBUG)
AsyncSessionLocal = sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False
)


@celery_app.task
def send_identification_result_notification(user_id: str, identification_data: Dict[str, Any]):
    """发送植物识别结果通知"""
    try:
        result = asyncio.run(_send_identification_result_notification_async(user_id, identification_data))
        return {
            'status': 'SUCCESS',
            'result': result,
            'message': '识别结果通知发送成功'
        }
    except Exception as exc:
        return {
            'status': 'FAILURE',
            'error': str(exc),
            'message': '发送识别结果通知失败'
        }


async def _send_identification_result_notification_async(user_id: str, identification_data: Dict[str, Any]) -> Dict[str, Any]:
    """异步发送植物识别结果通知"""
    async with AsyncSessionLocal() as db:
        user_service = UserService(db)
        user = await user_service.get_by_id(user_id)
        
        if not user:
            raise ValueError("用户不存在")
        
        # 这里应该实现实际的通知发送逻辑
        # 例如：推送通知、邮件通知等
        
        return {
            'user_id': user_id,
            'notification_type': 'identification_result',
            'sent': True
        }


@celery_app.task
def send_video_generation_notification(user_id: str, video_data: Dict[str, Any]):
    """发送视频生成完成通知"""
    try:
        result = asyncio.run(_send_video_generation_notification_async(user_id, video_data))
        return {
            'status': 'SUCCESS',
            'result': result,
            'message': '视频生成通知发送成功'
        }
    except Exception as exc:
        return {
            'status': 'FAILURE',
            'error': str(exc),
            'message': '发送视频生成通知失败'
        }


async def _send_video_generation_notification_async(user_id: str, video_data: Dict[str, Any]) -> Dict[str, Any]:
    """异步发送视频生成完成通知"""
    async with AsyncSessionLocal() as db:
        user_service = UserService(db)
        user = await user_service.get_by_id(user_id)
        
        if not user:
            raise ValueError("用户不存在")
        
        # 实现视频生成完成通知逻辑
        
        return {
            'user_id': user_id,
            'notification_type': 'video_generation',
            'video_url': video_data.get('video_url'),
            'sent': True
        }


@celery_app.task
def send_bulk_notifications(notification_data: Dict[str, Any]):
    """批量发送通知"""
    try:
        result = asyncio.run(_send_bulk_notifications_async(notification_data))
        return {
            'status': 'SUCCESS',
            'result': result,
            'message': f'批量通知发送完成，成功发送 {result["sent_count"]} 条'
        }
    except Exception as exc:
        return {
            'status': 'FAILURE',
            'error': str(exc),
            'message': '批量发送通知失败'
        }


async def _send_bulk_notifications_async(notification_data: Dict[str, Any]) -> Dict[str, Any]:
    """异步批量发送通知"""
    async with AsyncSessionLocal() as db:
        user_service = UserService(db)
        
        user_ids = notification_data.get('user_ids', [])
        message = notification_data.get('message', '')
        notification_type = notification_data.get('type', 'general')
        
        sent_count = 0
        failed_count = 0
        
        for user_id in user_ids:
            try:
                user = await user_service.get_by_id(user_id)
                if user and user.is_active:
                    # 发送通知逻辑
                    sent_count += 1
                else:
                    failed_count += 1
            except Exception:
                failed_count += 1
        
        return {
            'sent_count': sent_count,
            'failed_count': failed_count,
            'total_count': len(user_ids),
            'notification_type': notification_type
        }


@celery_app.task
def send_subscription_expiry_reminder(user_id: str):
    """发送订阅即将到期提醒"""
    try:
        result = asyncio.run(_send_subscription_expiry_reminder_async(user_id))
        return {
            'status': 'SUCCESS',
            'result': result,
            'message': '订阅到期提醒发送成功'
        }
    except Exception as exc:
        return {
            'status': 'FAILURE',
            'error': str(exc),
            'message': '发送订阅到期提醒失败'
        }


async def _send_subscription_expiry_reminder_async(user_id: str) -> Dict[str, Any]:
    """异步发送订阅即将到期提醒"""
    async with AsyncSessionLocal() as db:
        user_service = UserService(db)
        user = await user_service.get_by_id(user_id)
        
        if not user:
            raise ValueError("用户不存在")
        
        # 实现订阅到期提醒逻辑
        
        return {
            'user_id': user_id,
            'notification_type': 'subscription_expiry_reminder',
            'sent': True
        }
