"""数据库基类"""
import uuid
from datetime import datetime
from typing import Any
from sqlalchemy import Column, DateTime, String, Boolean
from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy.orm import DeclarativeBase


def get_now() -> datetime:
    """获取当前时间（自动使用系统时区）"""
    return datetime.now()


class Base(DeclarativeBase):
    """数据库模型基类"""
    
    @declared_attr
    def __tablename__(cls) -> str:
        # 自动生成表名（蛇形命名）
        import re
        name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', cls.__name__)
        return re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()


class TimestampMixin:
    """时间戳混入类"""
    created_at = Column(DateTime, default=get_now, nullable=False)
    updated_at = Column(DateTime, default=get_now, onupdate=get_now, nullable=False)


class UUIDMixin:
    """UUID 混入类"""
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()), index=True)


class SoftDeleteMixin:
    """软删除混入类"""
    is_deleted = Column(Boolean, default=False, nullable=False)
    deleted_at = Column(DateTime, nullable=True)
    
    def soft_delete(self):
        """执行软删除"""
        self.is_deleted = True
        self.deleted_at = get_now()


class BaseModel(Base, TimestampMixin, UUIDMixin):
    """基础模型类"""
    __abstract__ = True
    
    def to_dict(self) -> dict[str, Any]:
        """转换为字典"""
        return {
            column.name: getattr(self, column.name)
            for column in self.__table__.columns
        }