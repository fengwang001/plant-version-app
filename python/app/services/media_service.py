"""媒体文件服务"""
import os
import uuid
import requests
import json
from typing import Dict, Any, Optional
from fastapi import UploadFile
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from .base_service import BaseService
from .storage_service import StorageService
from ..models.media import MediaFile
from ..schemas.media import MediaFileResponse, MediaPresignResponse
from ..core.config import settings


class MediaService(BaseService[MediaFile]):
    """媒体文件服务类"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, MediaFile)
        self.storage_service = StorageService()
    
    async def generate_presign_url(
        self,
        user_id: str,
        filename: str,
        content_type: str,
        file_size: int,
        file_purpose: str
    ) -> MediaPresignResponse:
        """生成预签名上传URL"""
        
        # 验证文件类型
        allowed_types = {
            'avatar': ['image/jpeg', 'image/png', 'image/webp'],
            'plant_image': ['image/jpeg', 'image/png', 'image/webp'],
            'video': ['video/mp4', 'video/quicktime'],
            'document': ['application/pdf', 'text/plain']
        }
        
        if file_purpose not in allowed_types:
            raise ValueError(f"不支持的文件用途: {file_purpose}")
        
        if content_type not in allowed_types[file_purpose]:
            raise ValueError(f"不支持的文件类型: {content_type}")
        
        # 验证文件大小
        max_sizes = {
            'avatar': 5 * 1024 * 1024,  # 5MB
            'plant_image': 10 * 1024 * 1024,  # 10MB
            'video': 100 * 1024 * 1024,  # 100MB
            'document': 10 * 1024 * 1024  # 10MB
        }
        
        if file_size > max_sizes[file_purpose]:
            max_size_mb = max_sizes[file_purpose] / (1024 * 1024)
            raise ValueError(f"文件大小超过限制: {max_size_mb}MB")
        
        # 生成唯一文件名
        file_id = str(uuid.uuid4())
        file_extension = os.path.splitext(filename)[1]
        unique_filename = f"{file_id}{file_extension}"
        
        # 构建文件路径
        file_path = f"{file_purpose}/{user_id}/{unique_filename}"
        
        # 创建媒体文件记录
        media_file = MediaFile(
            id=file_id,
            user_id=user_id,
            filename=unique_filename,
            original_filename=filename,
            content_type=content_type,
            file_size=file_size,
            file_purpose=file_purpose,
            file_category=self._get_file_category(content_type),
            file_path=file_path,
            file_url="",  # 上传完成后更新
            status="pending",
            upload_progress=0,
            is_processed=False,
            is_public=file_purpose in ['plant_image'],
            is_deleted=False,
            view_count=0,
            download_count=0
        )
        
        self.db.add(media_file)
        await self.db.commit()
        await self.db.refresh(media_file)
        
        # 生成预签名URL（调用S3）
        presign_url = f"https://example.com/upload/{file_id}"
        url = " https://dbt96guful.execute-api.ap-southeast-2.amazonaws.com/fovus-api/create-resigned-url"
        headers = {"Content-Type": "application/json"}
        payload = {"fileName": unique_filename}

        response = requests.put(url, headers=headers, data=json.dumps(payload))
        #检查响应状态
        response.raise_for_status

        data = response.json()
        print(response.status_code)
        print(data)
        
        return MediaPresignResponse(
            file_id=file_id,
            presign_url=data,
            file_path=file_path,
            expires_in=3600  # 1小时
        )

    
    async def confirm_upload(
        self,
        file_id: str,
        user_id: str,
        file_url: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> MediaFileResponse:
        """确认文件上传完成"""
        
        media_file = await self.get_by_id(file_id)
        if not media_file:
            raise ValueError("文件记录不存在")
        
        if media_file.user_id != user_id:
            raise ValueError("无权限操作此文件")
        
        # 更新文件信息
        media_file.file_url = file_url
        media_file.status = "completed"
        media_file.upload_progress = 100
        media_file.is_processed = True
        
        if metadata:
            media_file.file_metadata = metadata
            # 从元数据中提取图片/视频尺寸信息
            if 'width' in metadata:
                media_file.width = metadata['width']
            if 'height' in metadata:
                media_file.height = metadata['height']
            if 'duration' in metadata:
                media_file.duration = metadata['duration']
        
        await self.db.commit()
        await self.db.refresh(media_file)
        
        return MediaFileResponse.model_validate(media_file)
    
    async def get_user_files(
        self,
        user_id: str,
        file_purpose: Optional[str] = None,
        skip: int = 0,
        limit: int = 20
    ) -> list[MediaFileResponse]:
        """获取用户的文件列表"""
        
        query = select(MediaFile).where(
            MediaFile.user_id == user_id,
            MediaFile.is_deleted == False
        )
        
        if file_purpose:
            query = query.where(MediaFile.file_purpose == file_purpose)
        
        query = query.order_by(MediaFile.created_at.desc()).offset(skip).limit(limit)
        
        result = await self.db.execute(query)
        files = result.scalars().all()
        
        return [MediaFileResponse.model_validate(file) for file in files]
    
    async def delete_file(self, file_id: str, user_id: str) -> bool:
        """删除文件"""
        
        media_file = await self.get_by_id(file_id)
        if not media_file:
            return False
        
        if media_file.user_id != user_id:
            raise ValueError("无权限删除此文件")
        
        # 软删除
        media_file.is_deleted = True
        await self.db.commit()
        
        return True
    
    async def upload_file_direct(
        self,
        file: UploadFile,
        user_id: str,
        file_purpose: str
    ) -> MediaFileResponse:
        """直接上传文件（用于开发环境）"""
        
        # 验证文件类型
        allowed_types = {
            'avatar': ['image/jpeg', 'image/png', 'image/webp'],
            'plant_image': ['image/jpeg', 'image/png', 'image/webp'],
            'video': ['video/mp4', 'video/quicktime'],
            'document': ['application/pdf', 'text/plain']
        }
        
        if file_purpose not in allowed_types:
            raise ValueError(f"不支持的文件用途: {file_purpose}")
        
        if file.content_type not in allowed_types[file_purpose]:
            raise ValueError(f"不支持的文件类型: {file.content_type}")
        
        # 验证文件大小
        max_sizes = {
            'avatar': 5 * 1024 * 1024,  # 5MB
            'plant_image': 10 * 1024 * 1024,  # 10MB
            'video': 100 * 1024 * 1024,  # 100MB
            'document': 10 * 1024 * 1024  # 10MB
        }
        
        # 读取文件内容获取大小
        content = await file.read()
        file_size = len(content)
        
        # 重置文件指针
        await file.seek(0)
        
        if file_size > max_sizes[file_purpose]:
            max_size_mb = max_sizes[file_purpose] / (1024 * 1024)
            raise ValueError(f"文件大小超过限制: {max_size_mb}MB")
        
        # 上传文件到存储服务
        upload_result = await self.storage_service.upload_file(
            file=file,
            file_purpose=file_purpose,
            user_id=user_id
        )
        
        # 创建媒体文件记录
        media_file = MediaFile(
            id=upload_result["file_id"],
            user_id=user_id,
            filename=upload_result["filename"],
            original_filename=upload_result["original_filename"],
            content_type=upload_result["content_type"],
            file_size=upload_result["file_size"],
            file_purpose=file_purpose,
            file_category=self.storage_service.get_file_category(upload_result["content_type"]),
            file_path=upload_result["file_path"],
            file_url=upload_result["file_url"],
            status="completed",
            upload_progress=100,
            is_processed=True,
            is_public=file_purpose in ['plant_image'],
            is_deleted=False,
            view_count=0,
            download_count=0
        )
        
        self.db.add(media_file)
        await self.db.commit()
        await self.db.refresh(media_file)
        
        return MediaFileResponse.model_validate(media_file)
    

    async def upload_file_to_s3(self,
        file: UploadFile,
        user_id: str,
        file_purpose: str) -> MediaFileResponse:
        """
        使用预签名URL上传文件到S3
        
        Args:
            file_path: 本地文件路径
            presigned_url: S3预签名URL
            content_type: 文件的MIME类型（可选，如 'image/jpeg', 'application/pdf'）
            
        Returns:
            bool: 上传是否成功
        """
        try:
            # 读取文件内容
            content = await file.read()
            file_size = len(content)  # 获取文件大小
            await file.seek(0)  # 重置文件指针
            # 生成预签名URL
            presigned_resonse = await self.generate_presign_url(
                user_id=user_id,
                filename=file.filename,
                content_type=file.content_type,
                file_size=file_size,
                file_purpose=file_purpose
            )   
            
            # 设置请求头
            headers = {
                'Content-Type': file.content_type
            }
       
            
            # 上传文件到S3
            response = requests.put(
                presigned_resonse.presign_url,
                data=file,
                headers=headers
            )
            
            # 检查上传是否成功
            if response.ok:
                print('File uploaded successfully')
                # 在Python中没有alert，使用print或者可以使用GUI库
                self.confirm_upload(
                    file_id=presigned_resonse.file_id, 
                    user_id=user_id, 
                    file_url=presigned_resonse.file_url
                )
                return True
            else:
                print(f'File upload failed: {response.status_code}')
                return False
                
        except Exception as error:
            print(f'Error uploading file: {error}')
            return False
    
    def _get_file_category(self, content_type: str) -> str:
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

