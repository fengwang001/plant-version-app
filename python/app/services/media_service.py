# app/services/media_service.py
"""媒体文件服务"""
import os
import uuid
import requests
import json
from typing import Dict, Any, Optional
from datetime import datetime, timedelta
from fastapi import UploadFile, HTTPException
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
        
        # 调用AWS API生成预签名URL
        try:
            url = "https://dbt96guful.execute-api.ap-southeast-2.amazonaws.com/fovus-api/create-resigned-url"
            headers = {"Content-Type": "application/json"}
            payload = {"fileName": unique_filename}

            response = requests.put(url, headers=headers, data=json.dumps(payload))
            response.raise_for_status()  # 修正：应该是方法调用，不是属性访问

            data = response.json()
            print(f"📡 AWS响应状态码: {response.status_code}")
            print(f"📡 AWS响应数据: {data}")
            
            # 从响应中提取预签名URL
            presign_url = data if isinstance(data, str) else data.get('url', data.get('presign_url', ''))
            
            if not presign_url:
                raise ValueError("未能从AWS获取预签名URL")
            
        except requests.RequestException as e:
            print(f"❌ 调用AWS API失败: {e}")
            raise ValueError(f"生成预签名URL失败: {str(e)}")
        
        return MediaPresignResponse(
            file_id=file_id,
            presign_url=presign_url,
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
            if 'width' in metadata:
                media_file.width = metadata['width']
            if 'height' in metadata:
                media_file.height = metadata['height']
            if 'duration' in metadata:
                media_file.duration = metadata['duration']
        
        await self.db.commit()
        await self.db.refresh(media_file)
        
        return MediaFileResponse.model_validate(media_file)
    
    async def upload_file_to_s3(
        self,
        file: UploadFile,
        user_id: str,
        file_purpose: str
    ) -> MediaFileResponse:
        """
        使用预签名URL上传文件到S3
        """
        try:
            print(f"🌱 开始上传文件到S3: {file.filename}")
            
            # 读取文件内容
            content = await file.read()
            file_size = len(content)
            await file.seek(0)  # 重置文件指针
            
            print(f"📊 文件大小: {file_size} bytes")
            
            # 1. 生成预签名URL
            presigned_response = await self.generate_presign_url(
                user_id=user_id,
                filename=file.filename,
                content_type=file.content_type,
                file_size=file_size,
                file_purpose=file_purpose
            )
            
            print(f"✅ 获取到预签名URL: {presigned_response.presign_url[:50]}...")
            
            # 2. 上传文件到S3
            headers = {
                'Content-Type': file.content_type
            }
            
            # 重新读取文件内容用于上传
            await file.seek(0)
            file_content = await file.read()
            
            response = requests.put(
                presigned_response.presign_url,
                data=file_content,  # 使用文件内容而不是文件对象
                headers=headers,
                timeout=60  # 添加超时
            )
            
            print(f"📡 S3上传响应: {response.status_code}")
            print(f"📡 S3响应内容: {response.text}")
            
            # 3. 检查上传是否成功
            if response.ok:
                print('✅ 文件上传成功')
                
                # 构建文件URL（根据你的S3配置）
                # 假设上传成功后文件URL是预签名URL去掉查询参数的部分
                file_url = presigned_response.presign_url.split('?')[0]
                
                # 4. 确认上传完成
                return await self.confirm_upload(
                    file_id=presigned_response.file_id,
                    user_id=user_id,
                    file_url=file_url
                )
            else:
                print(f'❌ 文件上传失败: {response.status_code}')
                print(f'❌ 响应内容: {response.text}')
                raise HTTPException(
                    status_code=500,
                    detail=f"文件上传到S3失败: {response.status_code}"
                )
                
        except ValueError as e:
            print(f'❌ 验证错误: {e}')
            raise HTTPException(status_code=400, detail=str(e))
        except Exception as e:
            print(f'❌ 上传文件异常: {e}')
            import traceback
            traceback.print_exc()
            raise HTTPException(status_code=500, detail=f"上传文件失败: {str(e)}")
    
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