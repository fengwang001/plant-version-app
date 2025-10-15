"""植物识别服务"""
import json
import httpx
from typing import List, Optional, Dict, Any
from fastapi import UploadFile
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from .base_service import BaseService
from .user_service import UserService
from .media_service import MediaService
from ..models.plant import PlantIdentification, Plant
from ..schemas.plant import (
    PlantIdentificationResponse, 
    PlantIdentificationSuggestion,
    PlantIdentificationCreate
)
from ..core.config import settings


class PlantIdentificationService(BaseService[PlantIdentification]):
    """植物识别服务类"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, PlantIdentification)
        self.user_service = UserService(db)
        self.media_service = MediaService(db)
    
    async def identify_plant(
        self,
        image_file: UploadFile,
        user_id: str,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        location_name: Optional[str] = None
    ) -> PlantIdentificationResponse:
        """执行植物识别"""
        
        # 1. 上传图片到存储服务
        media_file = await self.media_service.upload_file_to_s3(
            file=image_file,
            user_id=user_id,
            file_purpose="plant_image"
        )
        
        # 2. 调用 Plant.id API 进行识别（模拟实现）
        identification_result = await self._call_plant_id_api(media_file.file_url)
        
        if not identification_result:
            raise Exception("植物识别失败，请稍后重试")
        
        # 3. 解析识别结果
        suggestions = self._parse_identification_result(identification_result)
        
        if not suggestions:
            raise Exception("无法识别此植物，请尝试更清晰的照片")
        
        # 4. 获取最佳识别结果
        best_suggestion = suggestions[0]
        
        # 5. 保存识别记录
        identification_data = PlantIdentificationCreate(
            scientific_name=best_suggestion.scientific_name,
            common_name=best_suggestion.common_name,
            confidence=best_suggestion.confidence,
            image_url=image_url,
            suggestions=suggestions,
            latitude=latitude,
            longitude=longitude,
            location_name=location_name,
            identification_source="plant.id",
            request_id=identification_result.get("id")
        )
        
        identification = await self._save_identification(user_id, identification_data)
        
        # 6. 更新用户识别次数
        await self.user_service.increment_identification_count(user_id)
        
        # 7. 尝试关联植物百科信息
        plant_details = await self._get_plant_details(best_suggestion.scientific_name)
        
        # 8. 构建响应
        response = PlantIdentificationResponse(
            id=identification.id,
            scientific_name=identification.scientific_name,
            common_name=identification.common_name,
            confidence=identification.confidence,
            image_url=identification.image_url,
            suggestions=identification.suggestions,
            identification_source=identification.identification_source,
            processing_status=identification.processing_status,
            latitude=identification.latitude,
            longitude=identification.longitude,
            location_name=identification.location_name,
            plant_details=plant_details,
            created_at=identification.created_at,
            updated_at=identification.updated_at
        )
        
        return response
    
    async def get_user_identifications(
        self,
        user_id: str,
        skip: int = 0,
        limit: int = 20
    ) -> List[PlantIdentificationResponse]:
        """获取用户的识别历史"""
        result = await self.db.execute(
            select(PlantIdentification)
            .where(PlantIdentification.user_id == user_id)
            .order_by(desc(PlantIdentification.created_at))
            .offset(skip)
            .limit(limit)
        )
        
        identifications = result.scalars().all()
        
        # 转换为响应格式
        responses = []
        for identification in identifications:
            plant_details = await self._get_plant_details(identification.scientific_name)
            
            response = PlantIdentificationResponse(
                id=identification.id,
                scientific_name=identification.scientific_name,
                common_name=identification.common_name,
                confidence=identification.confidence,
                image_url=identification.image_url,
                suggestions=identification.suggestions,
                user_feedback=identification.user_feedback,
                user_notes=identification.user_notes,
                identification_source=identification.identification_source,
                processing_status=identification.processing_status,
                latitude=identification.latitude,
                longitude=identification.longitude,
                location_name=identification.location_name,
                plant_details=plant_details,
                created_at=identification.created_at,
                updated_at=identification.updated_at
            )
            responses.append(response)
        
        return responses
    
    async def get_identification_by_id(
        self,
        identification_id: str,
        user_id: str
    ) -> Optional[PlantIdentificationResponse]:
        """获取指定识别记录"""
        result = await self.db.execute(
            select(PlantIdentification)
            .where(
                PlantIdentification.id == identification_id,
                PlantIdentification.user_id == user_id
            )
        )
        
        identification = result.scalar_one_or_none()
        if not identification:
            return None
        
        plant_details = await self._get_plant_details(identification.scientific_name)
        
        return PlantIdentificationResponse(
            id=identification.id,
            scientific_name=identification.scientific_name,
            common_name=identification.common_name,
            confidence=identification.confidence,
            image_url=identification.image_url,
            suggestions=identification.suggestions,
            user_feedback=identification.user_feedback,
            user_notes=identification.user_notes,
            identification_source=identification.identification_source,
            processing_status=identification.processing_status,
            latitude=identification.latitude,
            longitude=identification.longitude,
            location_name=identification.location_name,
            plant_details=plant_details,
            created_at=identification.created_at,
            updated_at=identification.updated_at
        )
    
    async def delete_identification(
        self,
        identification_id: str,
        user_id: str
    ) -> bool:
        """删除识别记录"""
        result = await self.db.execute(
            select(PlantIdentification)
            .where(
                PlantIdentification.id == identification_id,
                PlantIdentification.user_id == user_id
            )
        )
        
        identification = result.scalar_one_or_none()
        if not identification:
            return False
        
        await self.db.delete(identification)
        await self.db.commit()
        return True
    
    async def _upload_image(self, image_file: UploadFile) -> str:
        """上传图片到存储服务"""
        # TODO: 实现真实的图片上传逻辑
        # 1. 上传到 S3 或其他对象存储
        # 2. 返回图片 URL
        
        # 临时实现：返回模拟 URL
        import uuid
        filename = f"plant_images/{uuid.uuid4()}.jpg"
        return f"https://storage.plantvision.app/{filename}"
    
    async def _call_plant_id_api(self, image_url: str) -> Optional[Dict[str, Any]]:
        """调用 Plant.id API"""
        if not settings.plant_id_api_key:
            # 如果没有配置 API 密钥，返回模拟数据
            return self._get_mock_plant_id_response()
        
        try:
            headers = {
                "Api-Key": settings.plant_id_api_key,
                "Content-Type": "application/json"
            }
            
            data = {
                "images": [image_url],
                "modifiers": ["crops_fast", "similar_images"],
                "plant_language": "zh",
                "plant_details": ["common_names", "url", "description", "taxonomy", "rank", "gbif_id", "inaturalist_id", "image", "synonyms", "edible_parts", "watering"]
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{settings.plant_id_api_url}/identification",
                    headers=headers,
                    json=data,
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    return response.json()
                else:
                    print(f"Plant.id API error: {response.status_code} - {response.text}")
                    return None
                    
        except Exception as e:
            print(f"Plant.id API call failed: {e}")
            return None
    
    def _get_mock_plant_id_response(self) -> Dict[str, Any]:
        """获取模拟的 Plant.id API 响应"""
        import random
        
        mock_plants = [
            {
                "species": {"scientificNameWithoutAuthor": "Rosa chinensis", "commonNames": ["月季花", "Chinese Rose"]},
                "probability": 0.85 + random.random() * 0.1
            },
            {
                "species": {"scientificNameWithoutAuthor": "Ficus benjamina", "commonNames": ["榕树", "Weeping Fig"]},
                "probability": 0.80 + random.random() * 0.1
            },
            {
                "species": {"scientificNameWithoutAuthor": "Aloe vera", "commonNames": ["芦荟", "True Aloe"]},
                "probability": 0.75 + random.random() * 0.1
            }
        ]
        
        selected_plant = random.choice(mock_plants)
        
        return {
            "id": f"mock_{random.randint(1000, 9999)}",
            "suggestions": [selected_plant] + random.sample([p for p in mock_plants if p != selected_plant], k=min(2, len(mock_plants) - 1))
        }
    
    def _parse_identification_result(self, result: Dict[str, Any]) -> List[PlantIdentificationSuggestion]:
        """解析识别结果"""
        suggestions = []
        
        for suggestion in result.get("suggestions", []):
            species = suggestion.get("species", {})
            scientific_name = species.get("scientificNameWithoutAuthor", "Unknown")
            common_names = species.get("commonNames", [])
            common_name = common_names[0] if common_names else scientific_name
            confidence = suggestion.get("probability", 0.0)
            
            suggestions.append(PlantIdentificationSuggestion(
                scientific_name=scientific_name,
                common_name=common_name,
                confidence=confidence,
                plant_details=species
            ))
        
        return suggestions
    
    async def _save_identification(
        self,
        user_id: str,
        identification_data: PlantIdentificationCreate
    ) -> PlantIdentification:
        """保存识别记录"""
        data_dict = identification_data.model_dump()
        data_dict['user_id'] = user_id
        
        return await self.create(data_dict)
    
    async def _get_plant_details(self, scientific_name: str) -> Optional[Dict[str, Any]]:
        """获取植物详细信息"""
        # TODO: 从植物百科表中查询详细信息
        result = await self.db.execute(
            select(Plant).where(Plant.scientific_name == scientific_name)
        )
        
        plant = result.scalar_one_or_none()
        if plant:
            return {
                "id": str(plant.id),
                "scientific_name": plant.scientific_name,
                "common_name": plant.common_name,
                "family": plant.family,
                "genus": plant.genus,
                "species": plant.species,
                "description": plant.description,
                "characteristics": plant.characteristics,
                "care_info": plant.care_info,
                "primary_image_url": plant.primary_image_url,
                "image_urls": plant.image_urls,
                "plant_type": plant.plant_type,
                "habitat": plant.habitat,
                "origin": plant.origin,
                "identification_count": plant.identification_count,
                "view_count": plant.view_count,
                "is_verified": plant.is_verified,
                "is_featured": plant.is_featured,
                "created_at": plant.created_at,
                "updated_at": plant.updated_at
            }
        
        return None
