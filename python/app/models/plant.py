"""植物相关模型"""
from sqlalchemy import Column, String, Text, Float, Integer, Boolean, JSON, ForeignKey
from sqlalchemy.orm import relationship
from ..db.base import BaseModel


class Plant(BaseModel):
    """
    植物模型
    用于存储植物的详细信息，包括基本信息、分类、特征、养护指南等
    """
    __tablename__ = "plants"
    
    
    # ========== 基本信息 ==========
    scientific_name = Column(
        String(255), 
        unique=True, 
        nullable=False, 
        index=True,
        comment="植物的学名（拉丁文），如 'Rosa chinensis'，全表唯一"
    )
    
    common_name = Column(
        String(255), 
        nullable=False, 
        index=True,
        comment="植物的常用名称，如 '月季花'，用于用户查询"
    )
    
    # ========== 分类信息 ==========
    family = Column(
        String(255), 
        nullable=True,
        comment="植物所属的科，如 '蔷薇科'"
    )
    
    genus = Column(
        String(255), 
        nullable=True,
        comment="植物所属的属，如 '蔷薇属'"
    )
    
    species = Column(
        String(255), 
        nullable=True,
        comment="植物的种名，如 '月季'"
    )
    
    # ========== 描述和特征 ==========
    description = Column(
        Text, 
        nullable=True,
        comment="植物的详细描述，100-200 字，包括外观、来源、用途等综合信息"
    )
    
    characteristics = Column(
        JSON, 
        nullable=True,
        comment="主要特征数组 JSON 格式，至少 5 个特征，如 ['特征1', '特征2', ...]"
    )
    
    # ========== 养护信息 ==========
    care_info = Column(
        JSON, 
        nullable=True,
        comment="""
        养护指南 JSON 格式，包含 4 个养护项：
        {
            "sunlight": {"requirement": "光照需求", "description": "详细说明"},
            "watering": {"requirement": "浇水频率", "description": "详细说明", "seasonal_variation": "季节变化"},
            "soil": {"requirement": "土壤要求", "description": "详细说明", "ph_range": "pH范围"},
            "temperature": {"requirement": "温度要求", "description": "详细说明", "cold_tolerance": "耐寒性"}
        }
        """
    )
    
    # ========== 植物分类和信息 ==========
    plant_type = Column(
        String(100), 
        nullable=True,
        comment="植物类型，如 '草本植物'、'木本植物'、'灌木'、'多肉植物' 等"
    )
    
    habitat = Column(
        String(255), 
        nullable=True,
        comment="原生地环境描述，如 '温带温带地区'、'热带雨林' 等"
    )
    
    origin = Column(
        String(255), 
        nullable=True,
        comment="植物原产地，如 '中国'、'欧洲' 等"
    )
    
    propagation_method = Column(
        String(255), 
        nullable=True,
        comment="植物繁殖方式，如 '种子'、'扦插'、'分株'、'嫁接' 等，多种用逗号分隔"
    )
    
    common_pests = Column(
        JSON, 
        nullable=True,
        comment="常见病虫害 JSON 数组，如 ['蚜虫', '红蜘蛛', '白粉病', '黑斑病']"
    )
    
    height_range = Column(
        String(100), 
        nullable=True,
        comment="植物的典型高度范围，如 '30-50cm' 或 '1-2m'"
    )
    
    blooming_period = Column(
        String(100), 
        nullable=True,
        comment="植物的花期，如 '3-5月' 或 '四季开花' 或 '5-11月'"
    )
    
    # ========== 安全信息 ==========
    toxicity = Column(
        Boolean, 
        default=False,
        comment="植物是否有毒，布尔值。True 表示有毒，False 表示无毒"
    )
    
    toxicity_description = Column(
        Text, 
        nullable=True,
        comment="毒性描述，说明有毒部位和毒性程度，如果无毒可为空或 '无毒'"
    )
    
    # ========== 图片和媒体 ==========
    primary_image_url = Column(
        String(500), 
        nullable=True,
        comment="植物的主图 URL，在列表页和详情页展示的主要图片"
    )
    
    image_urls = Column(
        JSON, 
        nullable=True,
        comment="其他植物图片 URL 数组 JSON 格式，如 ['url1', 'url2', 'url3']"
    )
    
    seasonal_images = Column(
        JSON, 
        nullable=True,
        comment="""
        四季植物图片 JSON 格式，展示植物在不同季节的外观：
        {
            "spring": [{"url": "链接", "description": "春季描述"}],
            "summer": [{"url": "链接", "description": "夏季描述"}],
            "autumn": [{"url": "链接", "description": "秋季描述"}],
            "winter": [{"url": "链接", "description": "冬季描述"}]
        }
        """
    )
    
    # ========== 元数据 ==========
    is_verified = Column(
        Boolean, 
        default=False, 
        index=True,
        comment="是否已验证。True 表示信息已审核确认，False 表示待审核"
    )
    
    is_featured = Column(
        Boolean, 
        default=False, 
        index=True,
        comment="是否为特色推荐植物。True 表示推荐在首页展示，False 表示普通植物"
    )
    
    view_count = Column(
        Integer, 
        default=0,
        comment="植物详情页被查看的次数，用于统计热度"
    )
    
    identification_count = Column(
        Integer, 
        default=0,
        comment="植物被识别的次数，用于统计流行度和排序"
    )
    
    # ========== 关系 ==========
    identifications = relationship(
        "PlantIdentification",
        back_populates="plant",
        foreign_keys="PlantIdentification.plant_id",
        cascade="all, delete-orphan"
    )
    
    def __repr__(self):
        return f"<Plant {self.scientific_name}>"

class PlantIdentification(BaseModel):
    """
    植物识别记录模型
    用于记录用户的植物识别请求和结果
    """
    __tablename__ = "plant_identification"
    
    # ========== 外键关系 ==========
    user_id = Column(
        String(36), 
        ForeignKey("user.id"), 
        nullable=False, 
        index=True,
        comment="发起识别的用户 ID，用于关联用户"
    )
    user = relationship("User", back_populates="plant_identifications")
    
    
    plant_id = Column(
        String(36), 
        ForeignKey('plants.id'),
        nullable=True, 
        index=True,
        comment="识别结果对应的植物 ID，如果找到匹配的植物则关联，否则为 NULL"
    )
    
    # ========== 识别结果 ==========
    scientific_name = Column(
        String(255), 
        nullable=False,
        comment="识别结果的植物学名，来自识别 API，如 'Rosa chinensis'"
    )
    
    common_name = Column(
        String(255), 
        nullable=False,
        comment="识别结果的植物常用名，来自识别 API，如 '月季花'"
    )
    
    confidence = Column(
        Float, 
        nullable=False,
        comment="识别置信度，取值范围 0-1，1 表示 100% 确信，值越大识别准确度越高"
    )
    
    # ========== 图片和建议 ==========
    image_url = Column(
        String(500), 
        nullable=False,
        comment="用户上传的识别图片 URL，保存在 S3 或本地服务器"
    )
    
    suggestions = Column(
        JSON, 
        nullable=True,
        comment="""
        识别建议列表 JSON 数组，包含多个可能的识别结果：
        [
            {"scientific_name": "学名", "common_name": "常用名", "confidence": 0.92},
            {"scientific_name": "学名", "common_name": "常用名", "confidence": 0.88},
            ...
        ]
        """
    )
    
    # ========== 位置信息 ==========
    latitude = Column(
        Float, 
        nullable=True,
        comment="拍摄地点的纬度坐标，用于地理定位和地区性植物推荐"
    )
    
    longitude = Column(
        Float, 
        nullable=True,
        comment="拍摄地点的经度坐标，用于地理定位和地区性植物推荐"
    )
    
    location_name = Column(
        String(255), 
        nullable=True,
        comment="拍摄地点的名称，如 '北京'、'公园' 等，用户可选填"
    )
    
    # ========== 用户反馈 ==========
    user_feedback = Column(
        String(50), 
        nullable=True,
        comment="用户对识别结果的反馈，可能的值：'correct'（正确）、'incorrect'（错误）、'unknown'（不确定）"
    )
    
    user_notes = Column(
        Text, 
        nullable=True,
        comment="用户对这个识别的附加说明或笔记"
    )
    
    # ========== 识别源和状态 ==========
    identification_source = Column(
        String(50), 
        nullable=True,
        comment="识别的来源 API，如 'plants.id'、'other_api' 等，用于区分不同的识别服务"
    )
    
    request_id = Column(
        String(255), 
        nullable=True,
        comment="外部 API 返回的请求 ID，用于追踪和日志记录"
    )
    
    processing_status = Column(
        String(50), 
        default="completed",
        comment="处理状态，可能的值：'completed'（已完成）、'pending'（待处理）、'failed'（失败）"
    )
    
    # ========== 关系 ==========
    plant = relationship(
        "Plant",
        back_populates="identifications",
        foreign_keys=[plant_id]
    )
    
    def __repr__(self):
        return f"<PlantIdentification {self.id}>"