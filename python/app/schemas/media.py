"""媒体文件相关的 Pydantic 模式"""
from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field, validator


class MediaPresignRequest(BaseModel):
    """媒体文件预签名请求"""
    filename: str = Field(..., max_length=255, description="文件名")
    content_type: str = Field(..., description="文件类型")
    file_size: int = Field(..., gt=0, le=100*1024*1024, description="文件大小（字节，最大100MB）")
    file_purpose: str = Field(..., description="文件用途")
    
    @validator('content_type')
    def validate_content_type(cls, v):
        allowed_types = [
            'image/jpeg', 'image/png', 'image/webp', 'image/gif',
            'video/mp4', 'video/quicktime', 'video/webm'
        ]
        if v not in allowed_types:
            raise ValueError(f'不支持的文件类型: {v}')
        return v
    
    @validator('file_purpose')
    def validate_file_purpose(cls, v):
        allowed_purposes = [
            'avatar', 'plant_image', 'plant_video', 'post_image', 'post_video'
        ]
        if v not in allowed_purposes:
            raise ValueError(f'不支持的文件用途: {v}')
        return v


class MediaPresignResponse(BaseModel):
    """媒体文件预签名响应"""
    media_id: str = Field(..., description="媒体文件ID")
    upload_url: str = Field(..., description="上传URL")
    upload_fields: Dict[str, str] = Field(default_factory=dict, description="上传表单字段")
    expires_at: datetime = Field(..., description="签名过期时间")
    max_file_size: int = Field(..., description="最大文件大小")


class MediaConfirmRequest(BaseModel):
    """确认上传请求"""
    media_id: str = Field(..., description="媒体文件ID")
    upload_success: bool = Field(..., description="上传是否成功")
    metadata: Optional[Dict[str, Any]] = Field(None, description="文件元数据")


class MediaFileResponse(BaseModel):
    """媒体文件响应"""
    id: str
    filename: str
    original_filename: str
    content_type: str
    file_size: int
    file_purpose: str
    file_url: str
    thumbnail_url: Optional[str] = None
    status: str
    metadata: Optional[Dict[str, Any]] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
    
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
