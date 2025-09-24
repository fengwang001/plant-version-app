"""用户相关 API"""
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from ....core import deps
from ....models.user import User
from ....schemas.user import UserResponse, UserUpdate, UserStats, UserProfile
from ....services.user_service import UserService

router = APIRouter()


@router.get("/me", response_model=UserResponse, summary="当前用户信息")
async def get_current_user_info(
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    """
    获取当前用户的基本信息
    """
    return current_user


@router.put("/me", response_model=UserResponse, summary="更新用户信息")
async def update_current_user(
    user_data: UserUpdate,
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    更新当前用户的信息
    """
    user_service = UserService(db)
    updated_user = await user_service.update_user(current_user.id, user_data)
    
    if not updated_user:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="更新用户信息失败"
        )
    
    return updated_user


@router.get("/me/stats", response_model=UserStats, summary="用户统计信息")
async def get_current_user_stats(
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取当前用户的统计信息
    """
    user_service = UserService(db)
    stats = await user_service.get_user_stats(current_user.id)
    
    if not stats:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户统计信息不存在"
        )
    
    return stats


@router.get("/me/profile", response_model=UserProfile, summary="用户详细资料")
async def get_current_user_profile(
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取当前用户的详细资料（包括统计信息）
    """
    user_service = UserService(db)
    stats = await user_service.get_user_stats(current_user.id)
    
    if not stats:
        stats = UserStats(
            identification_count=current_user.identification_count,
            video_generation_count=current_user.video_generation_count,
            post_count=0,
            like_count=0,
            follower_count=0,
            following_count=0
        )
    
    # 构建用户资料响应
    profile_data = {
        **current_user.__dict__,
        "stats": stats
    }
    
    return UserProfile(**profile_data)


@router.delete("/me", summary="注销账户")
async def delete_current_user(
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    注销当前用户账户（软删除）
    """
    user_service = UserService(db)
    success = await user_service.delete(current_user.id, soft=True)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="注销账户失败"
        )
    
    return {"message": "账户已注销"}


@router.post("/me/deactivate", summary="停用账户")
async def deactivate_current_user(
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    停用当前用户账户
    """
    user_service = UserService(db)
    success = await user_service.deactivate_user(current_user.id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="停用账户失败"
        )
    
    return {"message": "账户已停用"}
