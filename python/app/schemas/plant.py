"""植物相关的 Pydantic 模式"""
from datetime import datetime
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field, validator
import json


class PlantCareInfo(BaseModel):
    """植物养护信息"""
    sunlight: str = Field(..., description="光照需求")
    watering: str = Field(..., description="浇水频率")
    soil: str = Field(..., description="土壤要求")
    temperature: str = Field(..., description="温度要求")
    tips: List[str] = Field(default_factory=list, description="养护技巧")


class PlantBase(BaseModel):
    """植物基础信息"""
    scientific_name: str = Field(..., description="学名")
    common_name: str = Field(..., description="俗名")
    family: Optional[str] = Field(None, description="科")
    genus: Optional[str] = Field(None, description="属")
    species: Optional[str] = Field(None, description="种")


class PlantCreate(PlantBase):
    """创建植物"""
    description: Optional[str] = None
    characteristics: Optional[List[str]] = None
    care_info: Optional[PlantCareInfo] = None
    primary_image_url: Optional[str] = None
    image_urls: Optional[List[str]] = None
    plant_type: Optional[str] = None
    habitat: Optional[str] = None
    origin: Optional[str] = None
    data_source: Optional[str] = None
    external_id: Optional[str] = None

    # 兼容数据库中 JSON 各种形态，统一为字符串列表
    @validator('image_urls', pre=True)
    def normalize_image_urls_on_create(cls, value):
        """将 image_urls 统一转换为 List[str]
        支持以下输入：
        - None
        - str（如果是单个 URL 或 JSON 字符串）
        - dict（例如 {"url": "..."}）
        - list[str]
        - list[dict]（例如 [{"url": "..."}, ...]）
        """
        if value is None:
            return None
        # 如果是字符串，尝试作为 JSON 解析，否则当作单个 URL
        if isinstance(value, str):
            try:
                parsed = json.loads(value)
                value = parsed
            except Exception:
                return [value]
        # dict -> 提取常见键
        if isinstance(value, dict):
            url = value.get('url') or value.get('href') or value.get('src')
            return [url] if url else []
        # list -> 逐项规范化
        if isinstance(value, list):
            urls: List[str] = []
            for item in value:
                if isinstance(item, str):
                    urls.append(item)
                elif isinstance(item, dict):
                    u = item.get('url') or item.get('href') or item.get('src')
                    if u:
                        urls.append(u)
            return urls
        return value


class PlantResponse(PlantBase):
    """植物响应信息"""
    id: str
    description: Optional[str] = None
    characteristics: Optional[List[str]] = None
    care_info: Optional[PlantCareInfo] = None
    primary_image_url: Optional[str] = None
    image_urls: Optional[List[str]] = None
    plant_type: Optional[str] = None
    habitat: Optional[str] = None
    origin: Optional[str] = None
    identification_count: int
    view_count: int
    is_verified: bool
    is_featured: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

    # 兼容数据库 JSON，统一为 List[str]
    @validator('image_urls', pre=True)
    def normalize_image_urls_on_response(cls, value):
        """将 image_urls 统一转换为 List[str] 以通过校验"""
        if value is None:
            return None
        if isinstance(value, str):
            try:
                parsed = json.loads(value)
                value = parsed
            except Exception:
                return [value]
        if isinstance(value, dict):
            url = value.get('url') or value.get('href') or value.get('src')
            return [url] if url else []
        if isinstance(value, list):
            urls: List[str] = []
            for item in value:
                if isinstance(item, str):
                    urls.append(item)
                elif isinstance(item, dict):
                    u = item.get('url') or item.get('href') or item.get('src')
                    if u:
                        urls.append(u)
            return urls
        return value


class PlantSearchItem(BaseModel):
    """植物搜索项"""
    id: str
    scientific_name: str
    common_name: str
    primary_image_url: Optional[str] = None
    identification_count: int
    
    class Config:
        from_attributes = True


class PlantSearchResponse(BaseModel):
    """植物搜索结果"""
    plants: List[PlantSearchItem] = Field(..., description="植物列表")
    total: int = Field(..., description="总数量")
    has_more: bool = Field(..., description="是否还有更多")


class PlantIdentificationSuggestion(BaseModel):
    """植物识别候选"""
    scientific_name: str = Field(..., description="学名")
    common_name: str = Field(..., description="俗名")
    confidence: float = Field(..., ge=0, le=1, description="置信度")
    plant_details: Optional[Dict[str, Any]] = Field(None, description="植物详情")


class PlantIdentificationCreate(BaseModel):
    """创建植物识别记录"""
    scientific_name: str = Field(..., description="学名")
    common_name: str = Field(..., description="俗名")
    confidence: float = Field(..., ge=0, le=1, description="置信度")
    image_url: str = Field(..., description="图片URL")
    image_width: Optional[int] = Field(None, description="图片宽度")
    image_height: Optional[int] = Field(None, description="图片高度")
    suggestions: Optional[List[PlantIdentificationSuggestion]] = Field(None, description="识别候选")
    latitude: Optional[float] = Field(None, description="纬度")
    longitude: Optional[float] = Field(None, description="经度")
    location_name: Optional[str] = Field(None, description="位置名称")
    identification_source: str = Field(default="plant.id", description="识别来源")
    request_id: Optional[str] = Field(None, description="请求ID")
    
    @validator('confidence')
    def validate_confidence(cls, v):
        if not 0 <= v <= 1:
            raise ValueError('置信度必须在 0-1 之间')
        return v


class PlantIdentificationResponse(BaseModel):
    """植物识别响应"""
    id: str
    scientific_name: str
    common_name: str
    confidence: float
    image_url: str
    image_width: Optional[int] = None
    image_height: Optional[int] = None
    suggestions: Optional[List[PlantIdentificationSuggestion]] = None
    user_feedback: Optional[str] = None
    user_notes: Optional[str] = None
    identification_source: str
    processing_status: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location_name: Optional[str] = None
    plant_details: Optional[PlantResponse] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
    
    @property
    def confidence_percentage(self) -> int:
        """置信度百分比"""
        return int(self.confidence * 100)
    
    @property
    def is_high_confidence(self) -> bool:
        """是否高置信度"""
        return self.confidence >= 0.8


class PlantIdentificationFeedback(BaseModel):
    """植物识别反馈"""
    feedback: str = Field(..., pattern="^(correct|incorrect|unsure)$", description="反馈类型")
    notes: Optional[str] = Field(None, max_length=1000, description="备注")


class PlantIdentificationStats(BaseModel):
    """植物识别统计"""
    total_identifications: int = Field(..., description="总识别次数")
    high_confidence_count: int = Field(..., description="高置信度次数")
    average_confidence: float = Field(..., description="平均置信度")
    most_identified_plants: List[Dict[str, Any]] = Field(..., description="最常识别的植物")
    recent_identifications: List[PlantIdentificationResponse] = Field(..., description="最近识别")
