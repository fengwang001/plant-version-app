"""用户相关的 Pydantic 模式"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field


class UserBase(BaseModel):
    """用户基础信息"""
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    bio: Optional[str] = None


class UserCreate(UserBase):
    """创建用户"""
    password: Optional[str] = None
    device_id: Optional[str] = None
    device_type: Optional[str] = None


class UserUpdate(BaseModel):
    """更新用户信息"""
    username: Optional[str] = Field(None, max_length=100)
    full_name: Optional[str] = Field(None, max_length=255)
    avatar_url: Optional[str] = Field(None, max_length=500)
    bio: Optional[str] = Field(None, max_length=1000)
    language: Optional[str] = Field(None, max_length=10)
    timezone: Optional[str] = Field(None, max_length=50)


class UserResponse(UserBase):
    """用户响应信息"""
    id: str
    is_active: bool
    is_verified: bool
    user_type: str
    language: str
    timezone: str
    identification_count: int
    video_generation_count: int
    created_at: datetime
    last_login_at: Optional[datetime] = None
    
    # 游客用户相关字段
    device_id: Optional[str] = None
    device_type: Optional[str] = None
    is_guest: bool = False
    
    class Config:
        from_attributes = True


class UserStats(BaseModel):
    """用户统计信息"""
    identification_count: int = Field(..., description="识别次数")
    video_generation_count: int = Field(..., description="视频生成次数")
    post_count: int = Field(..., description="发布作品数")
    like_count: int = Field(..., description="获赞数")
    follower_count: int = Field(..., description="粉丝数")
    following_count: int = Field(..., description="关注数")


class UserProfile(UserResponse):
    """用户详细资料"""
    stats: UserStats
    
    @property
    def display_name(self) -> str:
        """显示名称"""
        if self.full_name:
            return self.full_name
        if self.username:
            return self.username
        if self.email:
            return self.email.split("@")[0]
        return f"用户{str(self.id)[:8]}"
    
    @property
    def is_guest(self) -> bool:
        """是否为游客用户"""
        return not self.email and not hasattr(self, 'apple_id') and not hasattr(self, 'google_id')
    
    @property
    def is_premium(self) -> bool:
        """是否为付费用户"""
        return self.user_type == "premium"
