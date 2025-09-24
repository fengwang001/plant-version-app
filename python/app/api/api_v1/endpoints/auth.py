"""认证相关 API"""
from datetime import timedelta
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from ....core import deps, security
from ....core.config import settings
from ....schemas.auth import (
    Token, 
    UserLogin, 
    UserRegister, 
    AppleLogin, 
    GoogleLogin,
    GuestLogin,
    RefreshToken
)
from ....schemas.user import UserResponse
from ....services.auth_service import AuthService

router = APIRouter()


@router.post("/register", response_model=UserResponse, summary="邮箱注册")
async def register(
    user_data: UserRegister,
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    邮箱注册新用户
    """
    auth_service = AuthService(db)
    user = await auth_service.register_with_email(
        email=user_data.email,
        password=user_data.password,
        full_name=user_data.full_name
    )
    return user


@router.post("/login", response_model=Token, summary="邮箱登录")
async def login(
    user_data: UserLogin,
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    邮箱密码登录
    """
    auth_service = AuthService(db)
    user = await auth_service.authenticate_with_email(
        email=user_data.email,
        password=user_data.password
    )
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="邮箱或密码错误"
        )
    
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    refresh_token_expires = timedelta(days=settings.refresh_token_expire_days)
    
    access_token = security.create_access_token(
        subject=user.id, expires_delta=access_token_expires
    )
    refresh_token = security.create_refresh_token(
        subject=user.id, expires_delta=refresh_token_expires
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
    }


@router.post("/login/apple", response_model=Token, summary="Apple 登录")
async def login_with_apple(
    apple_data: AppleLogin,
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    Apple Sign In 登录
    """
    auth_service = AuthService(db)
    user = await auth_service.authenticate_with_apple(
        identity_token=apple_data.identity_token,
        authorization_code=apple_data.authorization_code,
        user_info=apple_data.user_info
    )
    
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    refresh_token_expires = timedelta(days=settings.refresh_token_expire_days)
    
    access_token = security.create_access_token(
        subject=user.id, expires_delta=access_token_expires
    )
    refresh_token = security.create_refresh_token(
        subject=user.id, expires_delta=refresh_token_expires
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
    }


@router.post("/login/google", response_model=Token, summary="Google 登录")
async def login_with_google(
    google_data: GoogleLogin,
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    Google Sign In 登录
    """
    auth_service = AuthService(db)
    user = await auth_service.authenticate_with_google(
        id_token=google_data.id_token,
        access_token=google_data.access_token
    )
    
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    refresh_token_expires = timedelta(days=settings.refresh_token_expire_days)
    
    access_token = security.create_access_token(
        subject=user.id, expires_delta=access_token_expires
    )
    refresh_token = security.create_refresh_token(
        subject=user.id, expires_delta=refresh_token_expires
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
    }


@router.post("/login/guest", response_model=Token, summary="游客登录")
async def login_as_guest(
    guest_data: GuestLogin,
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    游客模式登录
    """
    auth_service = AuthService(db)
    user = await auth_service.create_guest_user(
        device_id=guest_data.device_id,
        device_type=guest_data.device_type
    )
    
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    refresh_token_expires = timedelta(days=settings.refresh_token_expire_days)
    
    access_token = security.create_access_token(
        subject=user.id, expires_delta=access_token_expires
    )
    refresh_token = security.create_refresh_token(
        subject=user.id, expires_delta=refresh_token_expires
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
    }


@router.post("/refresh", response_model=Token, summary="刷新令牌")
async def refresh_token(
    token_data: RefreshToken,
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    使用刷新令牌获取新的访问令牌
    """
    payload = security.decode_token(token_data.refresh_token)
    
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="无效的刷新令牌"
        )
    
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="无效的令牌负载"
        )
    
    # 验证用户是否存在且活跃
    from ....services.user_service import UserService
    user_service = UserService(db)
    user = await user_service.get_by_id(user_id)
    
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="用户不存在或已被禁用"
        )
    
    # 生成新的令牌
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    refresh_token_expires = timedelta(days=settings.refresh_token_expire_days)
    
    access_token = security.create_access_token(
        subject=user.id, expires_delta=access_token_expires
    )
    new_refresh_token = security.create_refresh_token(
        subject=user.id, expires_delta=refresh_token_expires
    )
    
    return {
        "access_token": access_token,
        "refresh_token": new_refresh_token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
    }


@router.post("/logout", summary="退出登录")
async def logout(
    current_user: deps.get_current_user = Depends()
) -> Any:
    """
    退出登录（客户端需要清除本地令牌）
    """
    return {"message": "退出登录成功"}
