"""基础服务类"""
from typing import TypeVar, Generic, Type, Optional, List, Any
from sqlalchemy import select, update, delete, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..db.base import BaseModel

ModelType = TypeVar("ModelType", bound=BaseModel)


class BaseService(Generic[ModelType]):
    """基础服务类，提供通用的 CRUD 操作"""
    
    def __init__(self, db: AsyncSession, model: Type[ModelType]):
        self.db = db
        self.model = model
    
    async def get_by_id(self, id: str) -> Optional[ModelType]:
        """根据 ID 获取单个记录"""
        result = await self.db.execute(
            select(self.model).where(self.model.id == id)
        )
        return result.scalar_one_or_none()
    
    async def get_multi(
        self, 
        skip: int = 0, 
        limit: int = 100,
        **filters
    ) -> List[ModelType]:
        """获取多个记录"""
        query = select(self.model)
        
        # 应用过滤条件
        for field, value in filters.items():
            if hasattr(self.model, field) and value is not None:
                query = query.where(getattr(self.model, field) == value)
        
        # 添加软删除过滤（如果模型支持）
        if hasattr(self.model, 'is_deleted'):
            query = query.where(self.model.is_deleted == False)
        
        query = query.offset(skip).limit(limit)
        result = await self.db.execute(query)
        return result.scalars().all()
    
    async def create(self, obj_data: dict) -> ModelType:
        """创建新记录"""
        db_obj = self.model(**obj_data)
        self.db.add(db_obj)
        await self.db.commit()
        await self.db.refresh(db_obj)
        return db_obj
    
    async def update(self, id: str, obj_data: dict) -> Optional[ModelType]:
        """更新记录"""
        # 移除 None 值
        update_data = {k: v for k, v in obj_data.items() if v is not None}
        
        if not update_data:
            return await self.get_by_id(id)
        
        stmt = (
            update(self.model)
            .where(self.model.id == id)
            .values(**update_data)
            .returning(self.model)
        )
        
        result = await self.db.execute(stmt)
        await self.db.commit()
        return result.scalar_one_or_none()
    
    async def delete(self, id: str, soft: bool = True) -> bool:
        """删除记录（默认软删除）"""
        obj = await self.get_by_id(id)
        if not obj:
            return False
        
        if soft and hasattr(obj, 'soft_delete'):
            obj.soft_delete()
            await self.db.commit()
        else:
            await self.db.delete(obj)
            await self.db.commit()
        
        return True
    
    async def count(self, **filters) -> int:
        """统计记录数量"""
        query = select(func.count(self.model.id))
        
        # 应用过滤条件
        for field, value in filters.items():
            if hasattr(self.model, field) and value is not None:
                query = query.where(getattr(self.model, field) == value)
        
        # 添加软删除过滤
        if hasattr(self.model, 'is_deleted'):
            query = query.where(self.model.is_deleted == False)
        
        result = await self.db.execute(query)
        return result.scalar()
    
    async def exists(self, **filters) -> bool:
        """检查记录是否存在"""
        query = select(self.model.id)
        
        for field, value in filters.items():
            if hasattr(self.model, field):
                query = query.where(getattr(self.model, field) == value)
        
        if hasattr(self.model, 'is_deleted'):
            query = query.where(self.model.is_deleted == False)
        
        result = await self.db.execute(query.limit(1))
        return result.scalar() is not None
