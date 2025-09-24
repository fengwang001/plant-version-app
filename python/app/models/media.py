"""媒体文件模型"""
from sqlalchemy import Column, String, Integer, Boolean, JSON, ForeignKey, Text
from sqlalchemy.orm import relationship
from ..db.base import BaseModel


class MediaFile(BaseModel):
    """媒体文件模型"""
    
    # 用户信息
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    
    # 文件基本信息
    filename = Column(String(255), nullable=False)  # 存储文件名
    original_filename = Column(String(255), nullable=False)  # 原始文件名
    content_type = Column(String(100), nullable=False)
    file_size = Column(Integer, nullable=False)
    
    # 文件用途和分类
    file_purpose = Column(String(50), nullable=False)  # avatar, plant_image, plant_video, etc.
    file_category = Column(String(20), nullable=False, default="image")  # image, video, document
    
    # 存储路径
    file_path = Column(String(500), nullable=False)  # S3 或其他存储的路径
    file_url = Column(String(500), nullable=False)  # 公开访问 URL
    thumbnail_url = Column(String(500), nullable=True)  # 缩略图 URL
    
    # 文件状态
    status = Column(String(20), default="uploading", nullable=False)  # uploading, completed, failed, deleted
    upload_progress = Column(Integer, default=0, nullable=False)  # 上传进度 0-100
    
    # 文件元数据
    file_metadata = Column(JSON, nullable=True)  # 额外的文件信息
    
    # 图片/视频特定信息
    width = Column(Integer, nullable=True)
    height = Column(Integer, nullable=True)
    duration = Column(Integer, nullable=True)  # 视频时长（秒）
    
    # 处理信息
    is_processed = Column(Boolean, default=False, nullable=False)
    processing_status = Column(String(20), nullable=True)  # processing, completed, failed
    processing_error = Column(Text, nullable=True)
    
    # 访问控制
    is_public = Column(Boolean, default=False, nullable=False)
    is_deleted = Column(Boolean, default=False, nullable=False)
    
    # 统计信息
    view_count = Column(Integer, default=0, nullable=False)
    download_count = Column(Integer, default=0, nullable=False)
    
    # 关联关系
    user = relationship("User", back_populates="media_files")
    
    def __repr__(self) -> str:
        return f"<MediaFile(id={self.id}, filename={self.filename}, user_id={self.user_id})>"
    
    @property
    def is_image(self) -> bool:
        """是否为图片文件"""
        return self.content_type.startswith('image/')
    
    @property
    def is_video(self) -> bool:
        """是否为视频文件"""
        return self.content_type.startswith('video/')
    
    @property
    def file_size_mb(self) -> float:
        """文件大小（MB）"""
        return round(self.file_size / (1024 * 1024), 2)
    
    @property
    def is_upload_completed(self) -> bool:
        """上传是否完成"""
        return self.status == "completed"
