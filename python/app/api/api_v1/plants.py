"""植物相关 API"""
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile, Query, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession

from ...core import deps
from ...models.user import User
from ...schemas.plant import (
    PlantResponse,
    PlantIdentificationResponse,
    PlantIdentificationCreate,
    PlantSearchResponse
)
from ...services.plant_service import PlantService
from ...services.plant_identification_service import PlantIdentificationService
from ...services.plant_details_service import PlantDetailsService

router = APIRouter()

async def _enrich_plant_details(
    db: AsyncSession,
    scientific_name: str,
    common_name: str,
    user_id: str
):
    """后台任务：获取植物详细信息"""
    try:
        service = PlantDetailsService(db)
        await service.enrich_plant_details(
            scientific_name=scientific_name,
            common_name=common_name,
            user_id=user_id
        )
        print(f"✅ 植物详细信息已保存: {scientific_name}")
    except Exception as e:
        print(f"❌ 后台任务失败: {e}")

@router.post("/identify", response_model=PlantIdentificationResponse, summary="植物识别")
async def identify_plant(
    file: UploadFile = File(..., description="植物图片"),
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    location_name: Optional[str] = None,
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db),
    background_tasks: BackgroundTasks  = BackgroundTasks()  # ✅ 正确的方式（无默认值）
) -> Any:
    """
    上传植物图片进行识别
    
    - **file**: 植物图片文件 (支持 JPEG, PNG, WebP)
    - **latitude**: 拍摄位置纬度（可选）
    - **longitude**: 拍摄位置经度（可选）
    - **location_name**: 位置名称（可选）
    """

    print(f"Received file: {file.filename}, content_type: {file.content_type}, size: {file.size if hasattr(file, 'size') else 'unknown'}")
    # 验证文件类型
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="只支持图片文件"
        )
    
    # 验证文件大小 (最大 10MB)
    if file.size and file.size > 10 * 1024 * 1024:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="图片文件不能超过 10MB"
        )
    
    identification_service = PlantIdentificationService(db)
    
    result = await identification_service.identify_plant(
        image_file=file,
        user_id=current_user.id,
        latitude=latitude,
        longitude=longitude,
        location_name=location_name
    )
    
    # 后台异步获取详细信息
    if background_tasks and result.scientific_name:
        background_tasks.add_task(
            _enrich_plant_details,
            db=db,
            scientific_name=result.scientific_name,
            common_name=result.common_name,
            user_id=current_user.id
        )
    
    return result


@router.get("/identifications", response_model=List[PlantIdentificationResponse], summary="识别历史")
async def get_identification_history(
    skip: int = Query(0, ge=0, description="跳过数量"),
    limit: int = Query(20, ge=1, le=100, description="返回数量"),
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取用户的植物识别历史记录
    """
    identification_service = PlantIdentificationService(db)
    results = await identification_service.get_user_identifications(
        user_id=current_user.id,
        skip=skip,
        limit=limit
    )
    return results


@router.get("/identifications/{identification_id}", response_model=PlantIdentificationResponse, summary="识别详情")
async def get_identification_detail(
    identification_id: str,
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取植物识别详情
    """
    identification_service = PlantIdentificationService(db)
    result = await identification_service.get_identification_by_id(
        identification_id=identification_id,
        user_id=current_user.id
    )
    
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="识别记录不存在"
        )
    
    return result


@router.get("/{plant_id}", response_model=PlantResponse, summary="植物详情")
async def get_plant_detail(
    plant_id: str,
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取植物详细信息
    """
    plant_service = PlantService(db)
    plant = await plant_service.get_by_id(plant_id)
    
    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="植物不存在"
        )
    
    # 增加查看次数
    await plant_service.increment_view_count(plant_id)
    
    return PlantResponse.model_validate(plant)


@router.get("/", response_model=PlantSearchResponse, summary="搜索植物")
async def search_plants(
    q: str = Query("", description="搜索关键词"),
    skip: int = Query(0, ge=0, description="跳过数量"),
    limit: int = Query(20, ge=1, le=100, description="返回数量"),
    verified_only: bool = Query(True, description="只返回已验证的植物"),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    搜索植物
    """
    plant_service = PlantService(db)
    result = await plant_service.search_plants(
        query=q,
        skip=skip,
        limit=limit,
        verified_only=verified_only
    )
    
    return result


@router.get("/featured/list", response_model=List[PlantResponse], summary="特色植物")
async def get_featured_plants(
    limit: int = Query(10, ge=1, le=50, description="返回数量"),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取特色植物列表
    """
    plant_service = PlantService(db)
    plants = await plant_service.get_featured_plants(limit=limit)
    return plants


@router.get("/popular/list", response_model=List[PlantResponse], summary="热门植物")
async def get_popular_plants(
    limit: int = Query(10, ge=1, le=50, description="返回数量"),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取热门植物列表
    """
    plant_service = PlantService(db)
    plants = await plant_service.get_popular_plants(limit=limit)
    return plants


@router.delete("/identifications/{identification_id}", summary="删除识别记录")
async def delete_identification(
    identification_id: str,
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    删除指定的识别记录
    """
    identification_service = PlantIdentificationService(db)
    success = await identification_service.delete_identification(
        identification_id=identification_id,
        user_id=current_user.id
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="识别记录不存在"
        )
    
    return {"message": "识别记录已删除"}


@router.get("/{plant_id}", response_model=PlantResponse, summary="植物详情")
async def get_plant_detail(
    plant_id: str,
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取植物详细信息
    """
    plant_service = PlantService(db)
    plant = await plant_service.get_by_id(plant_id)
    
    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="植物信息不存在"
        )
    
    return plant


@router.get("/", response_model=List[PlantResponse], summary="植物列表")
async def get_plants(
    skip: int = Query(0, ge=0, description="跳过数量"),
    limit: int = Query(20, ge=1, le=100, description="返回数量"),
    featured: Optional[bool] = Query(None, description="只显示推荐植物"),
    family: Optional[str] = Query(None, description="植物科属筛选"),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    获取植物列表
    """
    plant_service = PlantService(db)
    plants = await plant_service.get_plants(
        skip=skip,
        limit=limit,
        featured=featured,
        family=family
    )
    return plants


@router.get("/search", response_model=List[PlantSearchResponse], summary="植物搜索")
async def search_plants(
    q: str = Query(..., min_length=2, description="搜索关键词"),
    limit: int = Query(10, ge=1, le=50, description="返回数量"),
    db: AsyncSession = Depends(deps.get_db)
) -> Any:
    """
    搜索植物
    """
    plant_service = PlantService(db)
    results = await plant_service.search_plants(
        query=q,
        limit=limit
    )
    return results


