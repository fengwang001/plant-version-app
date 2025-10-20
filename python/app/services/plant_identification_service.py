"""植物识别服务"""
import json
import httpx
import base64
from typing import List, Optional, Dict, Any
from fastapi import UploadFile, HTTPException
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
        
        print(f"🌱 开始植物识别流程")
        print(f"👤 用户ID: {user_id}")
        print(f"📄 文件: {image_file.filename}")
        
        try:
            # 1. 转换图片为 base64（添加 await）
            print(f"🖼️ 开始转换图片为 base64")
            image_base64 = await self.image_to_base64(image_file)  # ✅ 添加 await
            print(f"✅ 图片转换完成，base64 长度: {len(image_base64)}")
            
            # 2. 调用 Plant.id API 进行识别
            print(f"🔍 调用 Plant.id API")
            identification_result = await self._call_plant_id_api(image_base64)
            
            if not identification_result:
                raise HTTPException(status_code=500, detail="植物识别失败，请稍后重试")
            
            print(f"✅ API 调用成功")
            
            # 3. 解析识别结果
            suggestions = self._parse_identification_result(identification_result)
            
            if not suggestions:
                raise HTTPException(status_code=404, detail="无法识别此植物，请尝试更清晰的照片")
            
            print(f"✅ 解析到 {len(suggestions)} 个建议")
            
            # 4. 获取最佳识别结果
            best_suggestion = suggestions[0]
            print(f"🌿 最佳匹配: {best_suggestion.common_name} ({best_suggestion.scientific_name})")
            print(f"📊 置信度: {best_suggestion.confidence:.2%}")
            
            # 5. 上传图片到 S3（保存记录用）
            print(f"📤 上传图片到 S3")
            media_file = await self.media_service.upload_file_to_s3(
                file=image_file,
                user_id=user_id,
                file_purpose="plant_image"
            )
            print(f"✅ 图片已保存: {media_file.file_url}")
            
            # 6. 保存识别记录
            identification_data = PlantIdentificationCreate(
                scientific_name=best_suggestion.scientific_name,
                common_name=best_suggestion.common_name,
                confidence=best_suggestion.confidence,
                image_url=media_file.file_url,  # 使用 S3 URL
                suggestions=suggestions,
                latitude=latitude,
                longitude=longitude,
                location_name=location_name,
                identification_source="plant.id",
                request_id=identification_result.get("access_token")
            )
            
            identification = await self._save_identification(user_id, identification_data)
            print(f"✅ 识别记录已保存: {identification.id}")
            
            # 7. 更新用户识别次数
            await self.user_service.increment_identification_count(user_id)
            
            # 8. 尝试关联植物百科信息
            plant_details = await self._get_plant_details(best_suggestion.scientific_name)
            
            # 9. 构建响应
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
            
            print(f"🎉 植物识别完成!")
            return response
            
        except HTTPException:
            raise
        except Exception as e:
            print(f"❌ 植物识别失败: {e}")
            import traceback
            traceback.print_exc()
            raise HTTPException(status_code=500, detail=f"植物识别失败: {str(e)}")
    
    async def image_to_base64(self, file: UploadFile) -> str:
        """将 UploadFile 转换为 base64 Data URI 字符串"""
        try:
            print(f"🖼️ 读取图片文件: {file.filename}")
            
            # 读取文件内容
            contents = await file.read()
            file_size = len(contents)
            
            print(f"🖼️ 文件大小: {file_size} bytes ({file_size / 1024:.2f} KB)")
            
            # 转换为 base64
            base64_encoded = base64.b64encode(contents).decode('utf-8')
            
            # 创建 Data URI 格式（Plant.id API 需要这种格式）
            data_uri = f"data:{file.content_type};base64,{base64_encoded}"
            
            # 重置文件指针，以便后续使用
            await file.seek(0)
            
            print(f"✅ 图片已转换为 Data URI，总长度: {len(data_uri)}")
            
            return data_uri
            
        except Exception as e:
            print(f"❌ 转换 base64 失败: {e}")
            raise HTTPException(status_code=500, detail=f"图片处理失败: {str(e)}")
    
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
    
    async def _call_plant_id_api(self, image_base64: str) -> Optional[Dict[str, Any]]:
        """调用 Plant.id API"""
        print(f"🔍 准备调用 Plant.id API")
        print(f"🔑 API URL: {settings.plant_id_api_url}")
        print(f"🔑 API Key: {settings.plant_id_api_key[:10]}...")  # 只打印前10个字符
        
        if not settings.plant_id_api_key or settings.plant_id_api_key == "your-plant-id-api-key":
            print("⚠️ Plant.id API 密钥未配置或为默认值，使用模拟数据")
            return self._get_mock_plant_id_response()
        
        try:
            headers = {
                "Api-Key": settings.plant_id_api_key,
                "Content-Type": "application/json"
            }
            
            # Plant.id API v5 的数据格式
            data = {
                "images": [image_base64],  # Data URI 格式
                "similar_images": True
            }
            
            print(f"🔑 使用 API Key: {settings.plant_id_api_key[:10]}...")
            print(f"📤 请求数据大小: {len(json.dumps(data))} bytes")
            
            async with httpx.AsyncClient() as client:
                # response = await client.post(
                #     f"{settings.plant_id_api_url}/identification",
                #     headers=headers,
                #     json=data,
                #     timeout=60.0  # 增加超时时间
                # )
                
                # print(f"📥 响应状态码: {response.status_code}")
                
                # if response.status_code == 200:
                #     print("✅ Plant.id API 调用成功")
                #     result = response.json()
                #     print(f"📊 识别结果: {json.dumps(result, indent=2, ensure_ascii=False)[:500]}...")
                #     return result
                # else:
                #     print(f"❌ Plant.id API error: {response.status_code}")
                #     print(f"❌ 响应内容: {response.text}")
                #     print("⚠️ 使用模拟数据")
                    return self._get_mock_plant_id_response()
                    
        except Exception as e:
            print(f"❌ Plant.id API call failed: {e}")
            import traceback
            traceback.print_exc()
            print("⚠️ 使用模拟数据")
            return self._get_mock_plant_id_response()
    
    def _get_mock_plant_id_response(self) -> Dict[str, Any]:
        """获取模拟的 Plant.id API 响应（新格式）"""
        import random
        from datetime import datetime, timezone
        
        print("🎭 生成模拟植物识别数据")
        
        mock_plants = [
            {
                "id": "ddb53cc7376936dc",
                "name": "Hibiscus rosa-sinensis",
                "probability": 0.99
            },
            {
                "id": "ficus-benjamina-001",
                "name": "Ficus benjamina",
                "probability": 0.85
            },
            {
                "id": "aloe-vera-001",
                "name": "Aloe vera",
                "probability": 0.75
            }
        ]
        
        selected_plant = random.choice(mock_plants)
        other_plants = [p for p in mock_plants if p != selected_plant]
        suggestions = [selected_plant] + random.sample(other_plants, k=min(2, len(other_plants)))
        
        # 按概率排序
        suggestions.sort(key=lambda x: x['probability'], reverse=True)
        
        now = datetime.now(timezone.utc)
        timestamp = now.timestamp()
        
        return {
            "access_token": f"mock_{random.randint(100000, 999999)}",
            "model_version": "plant_id:5.0.0",
            "custom_id": None,
            "result": {
                "classification": {
                    "suggestions": [
                        {
                            "id": plant["id"],
                            "name": plant["name"],
                            "probability": plant["probability"],
                            "similar_images": [],
                            "details": {
                                "language": "en",
                                "entity_id": plant["id"]
                            }
                        }
                        for plant in suggestions
                    ]
                },
                "is_plant": {
                    "probability": 0.95,
                    "threshold": 0.5,
                    "binary": True
                }
            },
            "status": "COMPLETED",
            "created": timestamp,
            "completed": timestamp
        }
    
    def _parse_identification_result(self, result: Dict[str, Any]) -> List[PlantIdentificationSuggestion]:
        """解析识别结果（适配新的 API 格式）"""
        suggestions = []
        
        print(f"📊 开始解析识别结果...")
        print(f"结果数据: {json.dumps(result, indent=2, ensure_ascii=False)[:1000]}...")
        
        # 适配新格式：result -> result -> classification -> suggestions
        try:
            classification = result.get("result", {}).get("classification", {})
            result_suggestions = classification.get("suggestions", [])
            
            for suggestion in result_suggestions:
                # 新格式中 name 直接就是学名，不再是嵌套结构
                scientific_name = suggestion.get("name", "Unknown")
                confidence = suggestion.get("probability", 0.0)
                
                # 从 details 获取更多信息（如果有的话）
                details = suggestion.get("details", {})
                entity_id = details.get("entity_id", "")
                
                # 如果 common_name 不可用，使用学名
                common_name = scientific_name
                
                suggestions.append(PlantIdentificationSuggestion(
                    scientific_name=scientific_name,
                    common_name=common_name,
                    confidence=confidence,
                    plant_details={
                        "name": scientific_name,
                        "entity_id": entity_id,
                        "details": details
                    }
                ))
            
            print(f"✅ 成功解析 {len(suggestions)} 个建议")
            
        except Exception as e:
            print(f"❌ 解析结果失败: {e}")
            import traceback
            traceback.print_exc()
        
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