"""认证相关的 Pydantic 模式"""
from typing import Optional
from pydantic import BaseModel, EmailStr, Field


class UserRegister(BaseModel):
    """用户注册请求"""
    email: EmailStr = Field(..., description="邮箱地址")
    password: str = Field(..., min_length=6, max_length=128, description="密码")
    full_name: Optional[str] = Field(None, max_length=255, description="全名")


class UserLogin(BaseModel):
    """用户登录请求"""
    email: EmailStr = Field(..., description="邮箱地址")
    password: str = Field(..., description="密码")


class AppleUserInfo(BaseModel):
    """Apple 用户信息"""
    given_name: Optional[str] = None
    family_name: Optional[str] = None
    email: Optional[str] = None


class AppleLogin(BaseModel):
    """Apple 登录请求"""
    identity_token: str = Field(..., description="Apple 身份令牌")
    authorization_code: Optional[str] = Field(None, description="授权码")
    user_info: Optional[AppleUserInfo] = Field(None, description="用户信息")


class GoogleLogin(BaseModel):
    """Google 登录请求"""
    id_token: str = Field(..., description="Google ID 令牌")
    access_token: Optional[str] = Field(None, description="访问令牌")


class GuestLogin(BaseModel):
    """游客登录请求"""
    device_id: str = Field(..., description="设备唯一标识")
    device_type: str = Field(..., description="设备类型 (ios/android/web/desktop)")


class Token(BaseModel):
    """令牌响应"""
    access_token: str = Field(..., description="访问令牌")
    refresh_token: str = Field(..., description="刷新令牌")
    token_type: str = Field(default="bearer", description="令牌类型")
    expires_in: int = Field(..., description="过期时间（秒）")


class RefreshToken(BaseModel):
    """刷新令牌请求"""
    refresh_token: str = Field(..., description="刷新令牌")


class TokenPayload(BaseModel):
    """令牌负载"""
    sub: Optional[str] = None
    exp: Optional[int] = None
    type: Optional[str] = None
