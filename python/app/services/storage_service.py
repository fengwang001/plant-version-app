"""存储服务 - 支持本地存储和S3存储"""
import os
import uuid
import aiofiles
from typing import Optional, Dict, Any
from fastapi import UploadFile
from pathlib import Path

from ..core.config import settings


class StorageService:
    """存储服务类"""
    
    def __init__(self):
        # 创建本地存储目录
        self.local_storage_path = Path("storage")
        self.local_storage_path.mkdir(exist_ok=True)
        
        # 创建不同用途的子目录
        for purpose in ["avatar", "plant_image", "video", "document"]:
            (self.local_storage_path / purpose).mkdir(exist_ok=True)
    
    async def upload_file(
        self,
        file: UploadFile,
        file_purpose: str,
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        上传文件
        
        Args:
            file: 上传的文件
            file_purpose: 文件用途 (avatar, plant_image, video, document)
            user_id: 用户ID（可选）
        
        Returns:
            包含文件信息的字典
        """
        
        # 生成唯一文件名
        file_id = str(uuid.uuid4())
        file_extension = self._get_file_extension(file.filename or "")
        unique_filename = f"{file_id}{file_extension}"
        
        # 构建文件路径
        if user_id:
            file_path = self.local_storage_path / file_purpose / user_id
        else:
            file_path = self.local_storage_path / file_purpose
        
        # 确保目录存在
        file_path.mkdir(parents=True, exist_ok=True)
        
        # 完整文件路径
        full_file_path = file_path / unique_filename
        
        # 保存文件
        async with aiofiles.open(full_file_path, 'wb') as f:
            content = await file.read()
            await f.write(content)
        
        # 构建文件URL（开发环境使用相对路径）
        relative_path = f"storage/{file_purpose}"
        if user_id:
            relative_path += f"/{user_id}"
        relative_path += f"/{unique_filename}"
        
        file_url = f"http://localhost:8000/{relative_path}"
        
        return {
            "file_id": file_id,
            "filename": unique_filename,
            "original_filename": file.filename or "unknown",
            "file_path": str(full_file_path),
            "file_url": file_url,
            "file_size": len(content),
            "content_type": file.content_type or "application/octet-stream"
        }
    
    async def delete_file(self, file_path: str) -> bool:
        """删除文件"""
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
                return True
            return False
        except Exception:
            return False
    
    def _get_file_extension(self, filename: str) -> str:
        """获取文件扩展名"""
        if not filename:
            return ""
        
        # 提取扩展名
        ext = os.path.splitext(filename)[1]
        if not ext:
            return ""
        
        return ext.lower()
    
    def get_file_category(self, content_type: str) -> str:
        """根据内容类型获取文件分类"""
        if content_type.startswith('image/'):
            return 'image'
        elif content_type.startswith('video/'):
            return 'video'
        elif content_type.startswith('audio/'):
            return 'audio'
        elif content_type in ['application/pdf', 'text/plain']:
            return 'document'
        else:
            return 'other'
