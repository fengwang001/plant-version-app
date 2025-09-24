"""植物相关模型"""
from sqlalchemy import Column, String, Text, Float, Integer, Boolean, JSON, ForeignKey
from sqlalchemy.orm import relationship
from ..db.base import BaseModel


class Plant(BaseModel):
    """植物百科模型"""
    
    # 基本信息
    scientific_name = Column(String(255), unique=True, index=True, nullable=False)
    common_name = Column(String(255), nullable=False)
    family = Column(String(100), nullable=True)
    genus = Column(String(100), nullable=True)
    species = Column(String(100), nullable=True)
    
    # 描述信息
    description = Column(Text, nullable=True)
    characteristics = Column(JSON, nullable=True)  # 特征列表
    
    # 养护信息
    care_info = Column(JSON, nullable=True)  # 养护指南
    growing_conditions = Column(JSON, nullable=True)  # 生长条件
    
    # 图片信息
    primary_image_url = Column(String(500), nullable=True)
    image_urls = Column(JSON, nullable=True)  # 多张图片
    
    # 分类信息
    plant_type = Column(String(50), nullable=True)  # 植物类型
    habitat = Column(String(100), nullable=True)  # 栖息地
    origin = Column(String(100), nullable=True)  # 原产地
    
    # 统计信息
    identification_count = Column(Integer, default=0, nullable=False)
    view_count = Column(Integer, default=0, nullable=False)
    
    # 状态
    is_verified = Column(Boolean, default=False, nullable=False)
    is_featured = Column(Boolean, default=False, nullable=False)
    
    # 数据源
    data_source = Column(String(50), nullable=True)  # plant.id, manual, etc.
    external_id = Column(String(100), nullable=True)  # 外部ID
    
    # 关联关系
    identifications = relationship("PlantIdentification", back_populates="plant")
    
    def __repr__(self) -> str:
        return f"<Plant(id={self.id}, scientific_name={self.scientific_name})>"


class PlantIdentification(BaseModel):
    """植物识别记录模型"""
    
    # 用户信息
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    
    # 植物信息
    plant_id = Column(String(36), ForeignKey("plant.id"), nullable=True, index=True)
    
    # 识别结果
    scientific_name = Column(String(255), nullable=False)
    common_name = Column(String(255), nullable=False)
    confidence = Column(Float, nullable=False)  # 置信度 0-1
    
    # 原始图片
    image_url = Column(String(500), nullable=False)
    image_width = Column(Integer, nullable=True)
    image_height = Column(Integer, nullable=True)
    
    # 识别详情
    suggestions = Column(JSON, nullable=True)  # 多个识别候选
    raw_response = Column(JSON, nullable=True)  # 原始API响应
    
    # 用户反馈
    user_feedback = Column(String(20), nullable=True)  # correct, incorrect, unsure
    user_notes = Column(Text, nullable=True)
    
    # 识别来源
    identification_source = Column(String(50), nullable=False)  # plant.id, manual, etc.
    request_id = Column(String(100), nullable=True)  # 外部请求ID
    
    # 处理状态
    processing_status = Column(String(20), default="completed", nullable=False)
    error_message = Column(Text, nullable=True)
    
    # 位置信息（可选）
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    location_name = Column(String(255), nullable=True)
    
    # 关联关系
    user = relationship("User", back_populates="identifications")
    plant = relationship("Plant", back_populates="identifications")
    
    def __repr__(self) -> str:
        return f"<PlantIdentification(id={self.id}, scientific_name={self.scientific_name}, confidence={self.confidence})>"
    
    @property
    def confidence_percentage(self) -> int:
        """置信度百分比"""
        return int(self.confidence * 100)
    
    @property
    def is_high_confidence(self) -> bool:
        """是否高置信度"""
        return self.confidence >= 0.8
