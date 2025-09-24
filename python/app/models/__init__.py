"""数据模型模块"""

# 导入所有模型以确保 Alembic 能够检测到
from .user import User
from .plant import Plant, PlantIdentification
from .media import MediaFile
from .subscription import Subscription, CreditTransaction
from .post import Post, PostLike, PostComment

__all__ = [
    "User",
    "Plant", 
    "PlantIdentification",
    "MediaFile",
    "Subscription",
    "CreditTransaction", 
    "Post",
    "PostLike",
    "PostComment",
]
