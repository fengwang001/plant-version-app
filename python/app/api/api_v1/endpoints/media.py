"""媒体文件相关 API"""
from typing import Any, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query, File, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from ....core import deps
from ....models.user import User
from ....schemas.media import (
    MediaPresignRequest,
    MediaPresignResponse,
    MediaConfirmRequest,
    MediaFileResponse
)
from ....services.media_service import MediaService

router = APIRouter()


@router.post("/upload", response_model=MediaFileResponse, summary="直接上传文件")
async def upload_file_direct(
    file: UploadFile = File(..., description="文件"),
    file_purpose: str = Query(..., description="文件用途 (avatar, plant_image, video, document)"),
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    直接上传文件（开发环境使用）
    
    - **file**: 要上传的文件
    - **file_purpose**: 文件用途
    """
    media_service = MediaService(db)
    
    try:
        result = await media_service.upload_file_direct(
            file=file,
            user_id=current_user.id,
            file_purpose=file_purpose
        )
        
        return result
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"文件上传失败: {str(e)}"
        )


@router.post("/presign", response_model=MediaPresignResponse, summary="获取上传签名")
async def get_upload_presign_url(
    request: MediaPresignRequest,
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取文件上传的预签名 URL
    
    - **filename**: 文件名
    - **content_type**: 文件类型 (image/jpeg, image/png, video/mp4 等)
    - **file_size**: 文件大小（字节）
    - **file_purpose**: 文件用途 (avatar, plant_image, video 等)
    """
    media_service = MediaService(db)
    
    try:
        presign_data = await media_service.generate_presign_url(
            user_id=current_user.id,
            filename=request.filename,
            content_type=request.content_type,
            file_size=request.file_size,
            file_purpose=request.file_purpose
        )
        
        return presign_data
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"生成上传签名失败: {str(e)}"
        )


@router.post("/confirm", response_model=MediaFileResponse, summary="确认上传完成")
async def confirm_upload(
    request: MediaConfirmRequest,
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    确认文件上传完成，创建媒体记录
    
    - **media_id**: 媒体文件 ID（从预签名响应中获取）
    - **upload_success**: 上传是否成功
    - **metadata**: 额外的文件元数据（可选）
    """
    media_service = MediaService(db)
    
    try:
        media_file = await media_service.confirm_upload(
            media_id=request.media_id,
            user_id=current_user.id,
            upload_success=request.upload_success,
            metadata=request.metadata
        )
        
        if not media_file:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="媒体文件不存在"
            )
        
        return media_file
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"确认上传失败: {str(e)}"
        )


@router.get("/{media_id}", response_model=MediaFileResponse, summary="获取媒体文件信息")
async def get_media_file(
    media_id: str,
    current_user: Optional[User] = Depends(deps.get_optional_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取媒体文件的详细信息
    """
    media_service = MediaService(db)
    
    media_file = await media_service.get_media_file(
        media_id=media_id,
        user_id=current_user.id if current_user else None
    )
    
    if not media_file:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="媒体文件不存在"
        )
    
    return media_file


@router.delete("/{media_id}", summary="删除媒体文件")
async def delete_media_file(
    media_id: str,
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    删除媒体文件
    """
    media_service = MediaService(db)
    
    success = await media_service.delete_media_file(
        media_id=media_id,
        user_id=current_user.id
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="媒体文件不存在或无权限删除"
        )
    
    return {"message": "媒体文件已删除"}


@router.get("/", response_model=list[MediaFileResponse], summary="获取用户媒体文件列表")
async def get_user_media_files(
    skip: int = Query(0, ge=0, description="跳过数量"),
    limit: int = Query(20, ge=1, le=100, description="返回数量"),
    file_purpose: Optional[str] = Query(None, description="文件用途筛选"),
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取当前用户的媒体文件列表
    """
    media_service = MediaService(db)
    
    media_files = await media_service.get_user_media_files(
        user_id=current_user.id,
        skip=skip,
        limit=limit,
        file_purpose=file_purpose
    )
    
    return media_files




