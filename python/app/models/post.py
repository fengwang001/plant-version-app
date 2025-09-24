"""作品和社区模型"""
from sqlalchemy import Column, String, Integer, Boolean, Text, ForeignKey, JSON, DateTime
from sqlalchemy.orm import relationship
from ..db.base import BaseModel, SoftDeleteMixin


class Post(BaseModel, SoftDeleteMixin):
    """作品/帖子模型"""
    
    # 作者信息
    author_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    
    # 基本信息
    title = Column(String(255), nullable=True)
    content = Column(Text, nullable=True)
    post_type = Column(String(20), default="image", nullable=False)  # image, video, text, plant_id
    
    # 媒体信息
    image_urls = Column(JSON, nullable=True)  # 图片URL列表
    video_url = Column(String(500), nullable=True)  # 视频URL
    thumbnail_url = Column(String(500), nullable=True)  # 缩略图URL
    
    # 植物识别相关（如果是植物识别分享）
    plant_identification_id = Column(String(36), ForeignKey("plant_identification.id"), nullable=True)
    plant_scientific_name = Column(String(255), nullable=True)
    plant_common_name = Column(String(255), nullable=True)
    
    # 分类和标签
    category = Column(String(50), nullable=True)  # 分类
    tags = Column(JSON, nullable=True)  # 标签列表
    
    # 位置信息
    latitude = Column(String(20), nullable=True)
    longitude = Column(String(20), nullable=True)
    location_name = Column(String(255), nullable=True)
    
    # 状态信息
    status = Column(String(20), default="published", nullable=False)  # draft, published, hidden, deleted
    is_featured = Column(Boolean, default=False, nullable=False)
    is_pinned = Column(Boolean, default=False, nullable=False)
    
    # 互动统计
    like_count = Column(Integer, default=0, nullable=False)
    comment_count = Column(Integer, default=0, nullable=False)
    share_count = Column(Integer, default=0, nullable=False)
    view_count = Column(Integer, default=0, nullable=False)
    
    # 审核信息
    is_reviewed = Column(Boolean, default=False, nullable=False)
    review_status = Column(String(20), nullable=True)  # pending, approved, rejected
    review_notes = Column(Text, nullable=True)
    reviewed_at = Column(DateTime, nullable=True)
    
    # 额外数据
    post_metadata = Column(JSON, nullable=True)
    
    # 关联关系
    author = relationship("User", back_populates="posts")
    plant_identification = relationship("PlantIdentification")
    likes = relationship("PostLike", back_populates="post")
    comments = relationship("PostComment", back_populates="post")
    
    def __repr__(self) -> str:
        return f"<Post(id={self.id}, title={self.title}, author_id={self.author_id})>"
    
    @property
    def is_published(self) -> bool:
        """是否已发布"""
        return self.status == "published" and not self.is_deleted
    
    @property
    def engagement_rate(self) -> float:
        """互动率"""
        if self.view_count == 0:
            return 0.0
        return (self.like_count + self.comment_count) / self.view_count


class PostLike(BaseModel):
    """作品点赞模型"""
    
    # 用户和作品
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    post_id = Column(String(36), ForeignKey("post.id"), nullable=False, index=True)
    
    # 点赞类型
    like_type = Column(String(20), default="like", nullable=False)  # like, love, wow, etc.
    
    # 关联关系
    user = relationship("User", back_populates="post_likes")
    post = relationship("Post", back_populates="likes")
    
    def __repr__(self) -> str:
        return f"<PostLike(id={self.id}, user_id={self.user_id}, post_id={self.post_id})>"


class PostComment(BaseModel, SoftDeleteMixin):
    """作品评论模型"""
    
    # 用户和作品
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    post_id = Column(String(36), ForeignKey("post.id"), nullable=False, index=True)
    
    # 评论内容
    content = Column(Text, nullable=False)
    
    # 回复关系
    parent_comment_id = Column(String(36), ForeignKey("post_comment.id"), nullable=True)
    reply_to_user_id = Column(String(36), ForeignKey("user.id"), nullable=True)
    
    # 统计信息
    like_count = Column(Integer, default=0, nullable=False)
    reply_count = Column(Integer, default=0, nullable=False)
    
    # 状态信息
    is_pinned = Column(Boolean, default=False, nullable=False)
    is_reviewed = Column(Boolean, default=False, nullable=False)
    review_status = Column(String(20), nullable=True)  # pending, approved, rejected
    
    # 关联关系
    user = relationship("User", back_populates="post_comments", foreign_keys=[user_id])
    post = relationship("Post", back_populates="comments")
    parent_comment = relationship("PostComment", remote_side="PostComment.id")
    reply_to_user = relationship("User", foreign_keys=[reply_to_user_id])
    
    def __repr__(self) -> str:
        return f"<PostComment(id={self.id}, user_id={self.user_id}, post_id={self.post_id})>"
    
    @property
    def is_reply(self) -> bool:
        """是否为回复评论"""
        return self.parent_comment_id is not None
