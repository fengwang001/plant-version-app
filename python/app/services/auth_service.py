"""认证服务"""
from typing import Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession

from .user_service import UserService
from ..models.user import User
from ..schemas.auth import AppleUserInfo


class AuthService:
    """认证服务类"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
        self.user_service = UserService(db)
    
    async def register_with_email(
        self,
        email: str,
        password: str,
        full_name: Optional[str] = None
    ) -> User:
        """邮箱注册"""
        # 检查邮箱是否已存在
        existing_user = await self.user_service.get_by_email(email)
        if existing_user:
            raise ValueError("邮箱已被注册")
        
        # 创建新用户
        user = await self.user_service.create_email_user(
            email=email,
            password=password,
            full_name=full_name
        )
        
        return user
    
    async def authenticate_with_email(
        self,
        email: str,
        password: str
    ) -> Optional[User]:
        """邮箱密码认证"""
        user = await self.user_service.authenticate(email, password)
        if user:
            await self.user_service.update_last_login(user.id)
        return user
    
    async def authenticate_with_apple(
        self,
        identity_token: str,
        authorization_code: Optional[str] = None,
        user_info: Optional[AppleUserInfo] = None
    ) -> User:
        """Apple Sign In 认证"""
        # TODO: 验证 Apple identity token
        # 这里需要实现 Apple JWT 令牌验证
        apple_user_id = await self._verify_apple_token(identity_token)
        
        if not apple_user_id:
            raise ValueError("无效的 Apple 令牌")
        
        # 查找现有用户
        user = await self.user_service.get_by_apple_id(apple_user_id)
        
        if not user:
            # 创建新用户
            full_name = None
            email = None
            
            if user_info:
                if user_info.given_name and user_info.family_name:
                    full_name = f"{user_info.given_name} {user_info.family_name}"
                elif user_info.given_name:
                    full_name = user_info.given_name
                email = user_info.email
            
            user = await self.user_service.create_apple_user(
                apple_id=apple_user_id,
                email=email,
                full_name=full_name
            )
        
        await self.user_service.update_last_login(user.id)
        return user
    
    async def authenticate_with_google(
        self,
        id_token: str,
        access_token: Optional[str] = None
    ) -> User:
        """Google Sign In 认证"""
        # TODO: 验证 Google ID token
        google_user_info = await self._verify_google_token(id_token)
        
        if not google_user_info:
            raise ValueError("无效的 Google 令牌")
        
        google_user_id = google_user_info.get('sub')
        
        # 查找现有用户
        user = await self.user_service.get_by_google_id(google_user_id)
        
        if not user:
            # 创建新用户
            user = await self.user_service.create_google_user(
                google_id=google_user_id,
                email=google_user_info.get('email'),
                full_name=google_user_info.get('name'),
                avatar_url=google_user_info.get('picture')
            )
        
        await self.user_service.update_last_login(user.id)
        return user
    
    async def create_guest_user(
        self,
        device_id: str,
        device_type: str
    ) -> User:
        """创建游客用户"""
        # 检查设备是否已有游客账户
        existing_user = await self.user_service.get_by_device_id(device_id)
        if existing_user:
            await self.user_service.update_last_login(existing_user.id)
            return existing_user
        
        # 创建新的游客用户
        user = await self.user_service.create_guest_user(
            device_id=device_id,
            device_type=device_type
        )
        
        await self.user_service.update_last_login(user.id)
        return user
    
    async def _verify_apple_token(self, identity_token: str) -> Optional[str]:
        """验证 Apple JWT 令牌"""
        # TODO: 实现 Apple JWT 令牌验证
        # 1. 获取 Apple 公钥
        # 2. 验证令牌签名
        # 3. 检查令牌有效期
        # 4. 验证 audience 和 issuer
        # 5. 返回用户 ID (sub)
        
        # 临时实现：直接解析令牌（生产环境必须验证）
        try:
            import jwt
            # 注意：这里没有验证签名，仅用于开发测试
            payload = jwt.decode(identity_token, options={"verify_signature": False})
            return payload.get('sub')
        except Exception:
            return None
    
    async def _verify_google_token(self, id_token: str) -> Optional[Dict[str, Any]]:
        """验证 Google ID 令牌"""
        # TODO: 实现 Google ID 令牌验证
        # 1. 使用 Google API 验证令牌
        # 2. 检查 audience 和 issuer
        # 3. 返回用户信息
        
        # 临时实现：直接解析令牌（生产环境必须验证）
        try:
            import jwt
            # 注意：这里没有验证签名，仅用于开发测试
            payload = jwt.decode(id_token, options={"verify_signature": False})
            return payload
        except Exception:
            return None
