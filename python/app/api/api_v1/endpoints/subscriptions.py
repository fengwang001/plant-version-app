"""订阅和积分相关 API"""
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from ....core import deps
from ....models.user import User

router = APIRouter()


@router.get("/me", summary="当前订阅信息")
async def get_current_subscription(
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取当前用户的订阅信息
    """
    # TODO: 实现订阅信息查询
    return {
        "user_id": str(current_user.id),
        "subscription_type": "free",
        "status": "active",
        "expires_at": None,
        "features": {
            "monthly_video_quota": 5,
            "used_video_quota": current_user.video_generation_count,
            "unlimited_identification": True
        }
    }


@router.post("/iap/validate", summary="验证 IAP 购买")
async def validate_iap_purchase(
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    验证 Apple/Google 应用内购买
    """
    # TODO: 实现 IAP 票据验证
    return {"message": "IAP 验证功能开发中"}


@router.get("/credits/me", summary="积分余额")
async def get_credit_balance(
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取当前用户的积分余额
    """
    # TODO: 实现积分系统
    return {
        "user_id": str(current_user.id),
        "video_credits": max(0, 5 - current_user.video_generation_count),
        "total_credits_purchased": 0,
        "total_credits_used": current_user.video_generation_count
    }


@router.post("/credits/consume", summary="消费积分")
async def consume_credits(
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    消费积分（用于视频生成等）
    """
    # TODO: 实现积分消费逻辑
    return {"message": "积分消费功能开发中"}
