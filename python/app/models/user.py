"""用户模型"""
from sqlalchemy import Column, String, Boolean, DateTime, Text, Integer
from sqlalchemy.orm import relationship
from ..db.base import BaseModel, SoftDeleteMixin


class User(BaseModel, SoftDeleteMixin):
    """用户模型"""
    
    # 基本信息
    email = Column(String(255), unique=True, index=True, nullable=True)
    username = Column(String(100), unique=True, index=True, nullable=True)
    full_name = Column(String(255), nullable=True)
    avatar_url = Column(String(500), nullable=True)
    
    # 认证信息
    hashed_password = Column(String(255), nullable=True)  # 邮箱注册用户才有密码
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    
    # 第三方登录
    apple_id = Column(String(255), unique=True, index=True, nullable=True)
    google_id = Column(String(255), unique=True, index=True, nullable=True)
    
    # 设备信息
    device_id = Column(String(255), nullable=True)
    device_type = Column(String(50), nullable=True)  # ios, android, web, desktop
    device_token = Column(String(500), nullable=True)  # 推送令牌
    
    # 用户偏好
    language = Column(String(10), default="zh", nullable=False)
    timezone = Column(String(50), default="Asia/Shanghai", nullable=False)
    
    # 统计信息
    identification_count = Column(Integer, default=0, nullable=False)
    video_generation_count = Column(Integer, default=0, nullable=False)
    
    # 最后活跃时间
    last_login_at = Column(DateTime, nullable=True)
    last_active_at = Column(DateTime, nullable=True)
    
    # 用户类型
    user_type = Column(String(20), default="regular", nullable=False)  # regular, premium, admin
    
    # 备注
    bio = Column(Text, nullable=True)
    
    # 关联关系
    identifications = relationship("PlantIdentification", back_populates="user", lazy="dynamic")
    media_files = relationship("MediaFile", back_populates="user", lazy="dynamic")
    subscriptions = relationship("Subscription", back_populates="user", lazy="dynamic")
    credit_transactions = relationship("CreditTransaction", back_populates="user", lazy="dynamic")
    posts = relationship("Post", back_populates="author", lazy="dynamic")
    post_likes = relationship("PostLike", back_populates="user", lazy="dynamic")
    post_comments = relationship("PostComment", back_populates="user", foreign_keys="PostComment.user_id", lazy="dynamic")
    
    def __repr__(self) -> str:
        return f"<User(id={self.id}, email={self.email}, username={self.username})>"
    
    @property
    def is_guest(self) -> bool:
        """是否为游客用户"""
        return not self.email and not self.apple_id and not self.google_id
    
    @property
    def is_premium(self) -> bool:
        """是否为付费用户"""
        return self.user_type == "premium"
    
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
