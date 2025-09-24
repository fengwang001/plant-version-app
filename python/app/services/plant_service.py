"""植物服务"""
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, or_
from sqlalchemy.orm import selectinload

from .base_service import BaseService
from ..models.plant import Plant
from ..schemas.plant import PlantResponse, PlantSearchResponse


class PlantService(BaseService[Plant]):
    """植物服务类"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, Plant)
    
    async def search_plants(
        self,
        query: str,
        skip: int = 0,
        limit: int = 20,
        verified_only: bool = True
    ) -> PlantSearchResponse:
        """搜索植物"""
        
        # 构建搜索条件
        search_conditions = []
        if query:
            search_conditions.extend([
                Plant.scientific_name.ilike(f"%{query}%"),
                Plant.common_name.ilike(f"%{query}%"),
                Plant.family.ilike(f"%{query}%"),
                Plant.genus.ilike(f"%{query}%"),
                Plant.species.ilike(f"%{query}%")
            ])
        
        # 构建基础查询
        base_query = select(Plant)
        
        if verified_only:
            base_query = base_query.where(Plant.is_verified == True)
        
        if search_conditions:
            base_query = base_query.where(or_(*search_conditions))
        
        # 获取总数
        count_query = select(func.count()).select_from(base_query.subquery())
        total_result = await self.db.execute(count_query)
        total = total_result.scalar_one()
        
        # 获取数据
        query_with_pagination = (
            base_query
            .order_by(Plant.identification_count.desc(), Plant.view_count.desc())
            .offset(skip)
            .limit(limit)
        )
        
        result = await self.db.execute(query_with_pagination)
        plants = result.scalars().all()
        
        from ..schemas.plant import PlantSearchItem
        return PlantSearchResponse(
            plants=[PlantSearchItem.model_validate(plant) for plant in plants],
            total=total,
            has_more=skip + len(plants) < total
        )
    
    async def get_featured_plants(self, limit: int = 10) -> List[PlantResponse]:
        """获取特色植物"""
        query = (
            select(Plant)
            .where(Plant.is_featured == True, Plant.is_verified == True)
            .order_by(Plant.view_count.desc())
            .limit(limit)
        )
        
        result = await self.db.execute(query)
        plants = result.scalars().all()
        
        return [PlantResponse.model_validate(plant) for plant in plants]
    
    async def get_popular_plants(self, limit: int = 10) -> List[PlantResponse]:
        """获取热门植物"""
        query = (
            select(Plant)
            .where(Plant.is_verified == True)
            .order_by(Plant.identification_count.desc(), Plant.view_count.desc())
            .limit(limit)
        )
        
        result = await self.db.execute(query)
        plants = result.scalars().all()
        
        return [PlantResponse.model_validate(plant) for plant in plants]
    
    async def increment_view_count(self, plant_id: str) -> None:
        """增加植物查看次数"""
        plant = await self.get_by_id(plant_id)
        if plant:
            plant.view_count += 1
            await self.db.commit()
    
    async def increment_identification_count(self, plant_id: str) -> None:
        """增加植物识别次数"""
        plant = await self.get_by_id(plant_id)
        if plant:
            plant.identification_count += 1
            await self.db.commit()
    
    async def get_by_scientific_name(self, scientific_name: str) -> Optional[Plant]:
        """根据学名获取植物"""
        query = select(Plant).where(Plant.scientific_name == scientific_name)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
    
    async def get_by_common_name(self, common_name: str) -> Optional[Plant]:
        """根据常用名获取植物"""
        query = select(Plant).where(Plant.common_name == common_name)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
