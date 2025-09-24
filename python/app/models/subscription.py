"""订阅和积分模型"""
from datetime import datetime
from sqlalchemy import Column, String, Integer, Boolean, DateTime, Float, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from ..db.base import BaseModel


class Subscription(BaseModel):
    """用户订阅模型"""
    
    # 用户信息
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    
    # 订阅信息
    subscription_type = Column(String(50), nullable=False)  # free, premium, enterprise
    plan_id = Column(String(100), nullable=True)  # RevenueCat 产品 ID
    
    # 订阅状态
    status = Column(String(20), default="active", nullable=False)  # active, expired, cancelled, paused
    
    # 订阅周期
    billing_period = Column(String(20), nullable=True)  # monthly, yearly, lifetime
    
    # 时间信息
    started_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    expires_at = Column(DateTime, nullable=True)
    cancelled_at = Column(DateTime, nullable=True)
    
    # 价格信息
    price = Column(Float, nullable=True)
    currency = Column(String(3), default="USD", nullable=False)
    
    # 平台信息
    platform = Column(String(20), nullable=True)  # apple, google, stripe
    platform_transaction_id = Column(String(255), nullable=True)
    platform_subscription_id = Column(String(255), nullable=True)
    
    # RevenueCat 信息
    revenuecat_subscriber_id = Column(String(255), nullable=True)
    revenuecat_original_transaction_id = Column(String(255), nullable=True)
    
    # 配额信息
    monthly_video_quota = Column(Integer, default=0, nullable=False)
    used_video_quota = Column(Integer, default=0, nullable=False)
    
    # 续订信息
    auto_renew = Column(Boolean, default=True, nullable=False)
    renewal_price = Column(Float, nullable=True)
    
    # 试用信息
    is_trial = Column(Boolean, default=False, nullable=False)
    trial_ends_at = Column(DateTime, nullable=True)
    
    # 额外数据
    subscription_metadata = Column(JSON, nullable=True)
    
    # 关联关系
    user = relationship("User", back_populates="subscriptions")
    
    def __repr__(self) -> str:
        return f"<Subscription(id={self.id}, user_id={self.user_id}, type={self.subscription_type})>"
    
    @property
    def is_active(self) -> bool:
        """订阅是否有效"""
        if self.status != "active":
            return False
        if self.expires_at and self.expires_at < datetime.utcnow():
            return False
        return True
    
    @property
    def is_expired(self) -> bool:
        """订阅是否过期"""
        if self.expires_at and self.expires_at < datetime.utcnow():
            return True
        return False
    
    @property
    def remaining_video_quota(self) -> int:
        """剩余视频配额"""
        return max(0, self.monthly_video_quota - self.used_video_quota)


class CreditTransaction(BaseModel):
    """积分交易记录模型"""
    
    # 用户信息
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    
    # 交易信息
    transaction_type = Column(String(20), nullable=False)  # purchase, consume, refund, bonus
    credit_type = Column(String(20), nullable=False)  # video_credit, premium_credit
    amount = Column(Integer, nullable=False)  # 积分数量（正数为增加，负数为消费）
    
    # 余额信息
    balance_before = Column(Integer, nullable=False)
    balance_after = Column(Integer, nullable=False)
    
    # 交易原因
    reason = Column(String(100), nullable=False)  # video_generation, subscription_bonus, purchase, etc.
    description = Column(Text, nullable=True)
    
    # 关联信息
    related_subscription_id = Column(String(36), ForeignKey("subscription.id"), nullable=True)
    related_order_id = Column(String(255), nullable=True)  # 外部订单 ID
    
    # 平台信息
    platform = Column(String(20), nullable=True)  # apple, google, stripe
    platform_transaction_id = Column(String(255), nullable=True)
    
    # 价格信息（如果是购买）
    price = Column(Float, nullable=True)
    currency = Column(String(3), nullable=True)
    
    # 状态
    status = Column(String(20), default="completed", nullable=False)  # pending, completed, failed, refunded
    
    # 额外数据
    subscription_metadata = Column(JSON, nullable=True)
    
    # 关联关系
    user = relationship("User", back_populates="credit_transactions")
    subscription = relationship("Subscription")
    
    def __repr__(self) -> str:
        return f"<CreditTransaction(id={self.id}, user_id={self.user_id}, type={self.transaction_type}, amount={self.amount})>"
    
    @property
    def is_credit(self) -> bool:
        """是否为积分增加"""
        return self.amount > 0
    
    @property
    def is_debit(self) -> bool:
        """是否为积分消费"""
        return self.amount < 0
