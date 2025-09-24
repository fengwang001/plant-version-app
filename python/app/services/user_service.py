"""用户服务"""
from typing import Optional, List
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from .base_service import BaseService
from ..models.user import User
from ..schemas.user import UserCreate, UserUpdate, UserStats
from ..core.security import get_password_hash, verify_password


class UserService(BaseService[User]):
    """用户服务类"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, User)
    
    async def get_by_email(self, email: str) -> Optional[User]:
        """根据邮箱获取用户"""
        result = await self.db.execute(
            select(User).where(User.email == email, User.is_deleted == False)
        )
        return result.scalar_one_or_none()
    
    async def get_by_username(self, username: str) -> Optional[User]:
        """根据用户名获取用户"""
        result = await self.db.execute(
            select(User).where(User.username == username, User.is_deleted == False)
        )
        return result.scalar_one_or_none()
    
    async def get_by_apple_id(self, apple_id: str) -> Optional[User]:
        """根据 Apple ID 获取用户"""
        result = await self.db.execute(
            select(User).where(User.apple_id == apple_id, User.is_deleted == False)
        )
        return result.scalar_one_or_none()
    
    async def get_by_google_id(self, google_id: str) -> Optional[User]:
        """根据 Google ID 获取用户"""
        result = await self.db.execute(
            select(User).where(User.google_id == google_id, User.is_deleted == False)
        )
        return result.scalar_one_or_none()
    
    async def get_by_device_id(self, device_id: str) -> Optional[User]:
        """根据设备 ID 获取用户（游客模式）"""
        result = await self.db.execute(
            select(User).where(
                User.device_id == device_id,
                User.email.is_(None),
                User.apple_id.is_(None),
                User.google_id.is_(None),
                User.is_deleted == False
            )
        )
        return result.scalar_one_or_none()
    
    async def create_user(self, user_data: UserCreate) -> User:
        """创建新用户"""
        user_dict = user_data.model_dump(exclude_unset=True)
        
        # 处理密码哈希
        if user_dict.get('password'):
            user_dict['hashed_password'] = get_password_hash(user_dict.pop('password'))
        
        return await self.create(user_dict)
    
    async def create_email_user(
        self, 
        email: str, 
        password: str, 
        full_name: Optional[str] = None
    ) -> User:
        """创建邮箱用户"""
        user_data = UserCreate(
            email=email,
            password=password,
            full_name=full_name
        )
        return await self.create_user(user_data)
    
    async def create_apple_user(
        self,
        apple_id: str,
        email: Optional[str] = None,
        full_name: Optional[str] = None
    ) -> User:
        """创建 Apple 用户"""
        user_dict = {
            'apple_id': apple_id,
            'email': email,
            'full_name': full_name,
            'is_verified': True,  # Apple 用户默认已验证
        }
        return await self.create(user_dict)
    
    async def create_google_user(
        self,
        google_id: str,
        email: Optional[str] = None,
        full_name: Optional[str] = None,
        avatar_url: Optional[str] = None
    ) -> User:
        """创建 Google 用户"""
        user_dict = {
            'google_id': google_id,
            'email': email,
            'full_name': full_name,
            'avatar_url': avatar_url,
            'is_verified': True,  # Google 用户默认已验证
        }
        return await self.create(user_dict)
    
    async def create_guest_user(
        self,
        device_id: str,
        device_type: str
    ) -> User:
        """创建游客用户"""
        user_dict = {
            'device_id': device_id,
            'device_type': device_type,
            'user_type': 'guest',
        }
        return await self.create(user_dict)
    
    async def authenticate(self, email: str, password: str) -> Optional[User]:
        """邮箱密码认证"""
        user = await self.get_by_email(email)
        if not user or not user.hashed_password:
            return None
        
        if not verify_password(password, user.hashed_password):
            return None
        
        return user
    
    async def update_user(self, user_id: str, user_data: UserUpdate) -> Optional[User]:
        """更新用户信息"""
        update_dict = user_data.model_dump(exclude_unset=True)
        return await self.update(user_id, update_dict)
    
    async def update_last_login(self, user_id: str) -> None:
        """更新最后登录时间"""
        from datetime import datetime
        await self.db.execute(
            update(User)
            .where(User.id == user_id)
            .values(last_login_at=datetime.utcnow(), last_active_at=datetime.utcnow())
        )
        await self.db.commit()
    
    async def increment_identification_count(self, user_id: str) -> None:
        """增加识别次数"""
        await self.db.execute(
            update(User)
            .where(User.id == user_id)
            .values(identification_count=User.identification_count + 1)
        )
        await self.db.commit()
    
    async def increment_video_generation_count(self, user_id: str) -> None:
        """增加视频生成次数"""
        await self.db.execute(
            update(User)
            .where(User.id == user_id)
            .values(video_generation_count=User.video_generation_count + 1)
        )
        await self.db.commit()
    
    async def get_user_stats(self, user_id: str) -> Optional[UserStats]:
        """获取用户统计信息"""
        user = await self.get_by_id(user_id)
        if not user:
            return None
        
        # TODO: 从其他表获取更多统计信息
        return UserStats(
            identification_count=user.identification_count,
            video_generation_count=user.video_generation_count,
            post_count=0,  # 待实现
            like_count=0,  # 待实现
            follower_count=0,  # 待实现
            following_count=0,  # 待实现
        )
    
    async def deactivate_user(self, user_id: str) -> bool:
        """停用用户账户"""
        return await self.update(user_id, {'is_active': False}) is not None
    
    async def activate_user(self, user_id: str) -> bool:
        """激活用户账户"""
        return await self.update(user_id, {'is_active': True}) is not None
    
    async def verify_user(self, user_id: str) -> bool:
        """验证用户邮箱"""
        return await self.update(user_id, {'is_verified': True}) is not None
