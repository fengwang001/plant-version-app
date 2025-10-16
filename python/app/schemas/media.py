# app/schemas/media.py
"""媒体相关的 Pydantic 模型"""
from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, Dict, Any, List


class MediaPresignRequest(BaseModel):
    """媒体预签名请求"""
    filename: str
    content_type: str
    file_size: int
    file_purpose: str
    
    model_config = ConfigDict(from_attributes=True)


class MediaPresignResponse(BaseModel):
    """媒体预签名响应"""
    file_id: str
    presign_url: str
    file_path: str
    expires_in: int
    
    model_config = ConfigDict(from_attributes=True)


class MediaConfirmRequest(BaseModel):
    """确认媒体上传请求"""
    file_url: str
    metadata: Optional[Dict[str, Any]] = None
    
    model_config = ConfigDict(from_attributes=True)


class MediaFileResponse(BaseModel):
    """媒体文件响应"""
    id: str
    user_id: str
    filename: str
    original_filename: str
    content_type: str
    file_size: int
    file_purpose: str
    file_category: str
    file_path: str
    file_url: str
    status: str
    upload_progress: int
    is_processed: bool
    is_public: bool
    is_deleted: bool
    view_count: int
    download_count: int
    file_metadata: Optional[Dict[str, Any]] = None
    width: Optional[int] = None
    height: Optional[int] = None
    duration: Optional[int] = None
    created_at: datetime
    updated_at: datetime
    
    model_config = ConfigDict(
        from_attributes=True,
        extra='ignore'
    )


class MediaFileCreate(BaseModel):
    """创建媒体文件请求"""
    filename: str
    content_type: str
    file_size: int
    file_purpose: str
    
    model_config = ConfigDict(from_attributes=True)


class MediaFileUpdate(BaseModel):
    """更新媒体文件请求"""
    is_public: Optional[bool] = None
    file_metadata: Optional[Dict[str, Any]] = None
    
    model_config = ConfigDict(from_attributes=True)


class MediaFileListResponse(BaseModel):
    """媒体文件列表响应"""
    files: List[MediaFileResponse]
    total: int
    has_more: bool
    
    model_config = ConfigDict(from_attributes=True)


class MediaUploadRequest(BaseModel):
    """媒体上传请求"""
    filename: str
    content_type: str
    file_size: int
    file_purpose: str
    
    model_config = ConfigDict(from_attributes=True)


class MediaConfirmUploadRequest(BaseModel):
    """确认上传完成请求"""
    file_id: str
    file_url: str
    metadata: Optional[Dict[str, Any]] = None
    
    model_config = ConfigDict(from_attributes=True)