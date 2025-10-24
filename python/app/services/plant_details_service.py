import json
import httpx
from typing import Optional, Dict, Any
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.services.base_service import BaseService
from app.models.plant import Plant
from app.core.config import settings
from app.core.exceptions import OpenAIAPIError, InvalidPlantDataError

class PlantDetailsService(BaseService[Plant]):
    """通过 OpenAI 获取植物详细信息的服务"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, Plant)
    
    async def enrich_plant_details(
        self,
        scientific_name: str,
        common_name: str,
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """获取植物详细信息并保存"""
        
        print(f"🤖 开始获取植物信息: {scientific_name}")
        
        try:
            # 1. 检查是否已存在
            existing = await self._get_plant_by_scientific_name(scientific_name)
            if existing and existing.description:
                print(f"✅ 植物信息已存在: {scientific_name}")
                return self._plant_to_dict(existing)
            
            # 2. 调用 OpenAI 获取信息
            plant_details = await self._fetch_plant_details_from_openai(
                scientific_name=scientific_name,
                common_name=common_name
            )
            
            # 3. 验证数据
            self._validate_plant_details(plant_details)
            
            # 4. 获取季节图片
            seasonal_images = await self._fetch_seasonal_images(
                scientific_name=scientific_name,
                common_name=common_name
            )
            plant_details['seasonal_images'] = seasonal_images
            
            # 5. 保存到数据库
            plant = await self._save_or_update_plant(
                scientific_name=scientific_name,
                common_name=common_name,
                plant_details=plant_details
            )
            
            print(f"✅ 植物信息已保存: {plant.id}")
            return self._plant_to_dict(plant)
            
        except Exception as e:
            print(f"❌ 获取植物信息失败: {e}")
            raise
    
    async def _fetch_plant_details_from_openai(
        self,
        scientific_name: str,
        common_name: str
    ) -> Dict[str, Any]:
        """调用 OpenAI API 获取植物详细信息"""
        
        prompt = self._build_plant_details_prompt(scientific_name, common_name)
        
        headers = {
            "Authorization": f"Bearer {settings.openai_api_key}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": settings.openai_model,
            "messages": [
                {
                    "role": "system",
                    "content": "你是一个植物学专家。请提供准确的植物信息，并使用 JSON 格式返回结构化数据。"
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            "temperature": 0.7,
            "max_tokens": 2000
        }
        
        print(f"📤 调用 OpenAI API")
        
        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(
                    "https://api.openai.com/v1/chat/completions",
                    headers=headers,
                    json=payload
                )
                
                if response.status_code != 200:
                    raise OpenAIAPIError(f"API error: {response.status_code}")
                
                result = response.json()
                content = result['choices'][0]['message']['content']
                
                print(f"✅ OpenAI API 调用成功")
                
                # 解析 JSON
                if "```json" in content:
                    json_str = content.split("```json")[1].split("```")[0].strip()
                elif "```" in content:
                    json_str = content.split("```")[1].split("```")[0].strip()
                else:
                    json_str = content
                
                plant_info = json.loads(json_str)
                print(f"✅ 成功解析 OpenAI 响应")
                return plant_info
                
        except json.JSONDecodeError as e:
            raise InvalidPlantDataError(f"无法解析 OpenAI 响应: {str(e)}")
        except Exception as e:
            raise OpenAIAPIError(f"OpenAI API 调用失败: {str(e)}")
    
    def _build_plant_details_prompt(self, scientific_name: str, common_name: str) -> str:
        """构建发送给 OpenAI 的提示词"""
        
        return f"""请提供关于以下植物的详细信息:
植物学名: {scientific_name}
常用名: {common_name}

请返回以下 JSON 格式的数据:

{{
    "scientific_name": "学名",
    "common_name": "常用名",
    "family": "科",
    "genus": "属",
    "species": "种",
    "description": "植物描述（100-200字）",
    "characteristics": [
        "特征1", "特征2", "特征3", "特征4", "特征5"
    ],
    "care_guide": {{
        "sunlight": {{
            "requirement": "光照需求",
            "description": "详细说明（50-100字）"
        }},
        "watering": {{
            "requirement": "浇水频率",
            "description": "详细说明",
            "seasonal_variation": "季节变化说明"
        }},
        "soil": {{
            "requirement": "土壤要求",
            "description": "详细说明",
            "ph_range": "pH 范围"
        }},
        "temperature": {{
            "requirement": "温度要求",
            "description": "详细说明",
            "cold_tolerance": "耐寒性说明"
        }}
    }},
    "plant_type": "植物类型",
    "habitat": "原生地环境",
    "origin": "原产地",
    "propagation_method": "繁殖方式",
    "common_pests": ["病虫害1", "病虫害2"],
    "height_range": "高度范围",
    "blooming_period": "花期",
    "toxicity": false,
    "toxicity_description": "无毒"
}}

重要: 所有字段都必须有值，特征至少5个，数据必须准确。"""
    
    async def _fetch_seasonal_images(
        self,
        scientific_name: str,
        common_name: str
    ) -> Dict[str, list]:
        """获取四季图片"""
        
        print(f"📸 获取季节性图片")
        
        try:
            headers = {
                "Authorization": f"Bearer {settings.openai_api_key}",
                "Content-Type": "application/json"
            }
            
            payload = {
                "model": settings.openai_model,
                "messages": [{
                    "role": "user",
                    "content": f"""请返回 {scientific_name}（{common_name}）四个季节的代表性图片。
返回 JSON: {{"spring": [{{"url": "", "description": ""}}], ...}}"""
                }],
                "max_tokens": 1000
            }
            
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    "https://api.openai.com/v1/chat/completions",
                    headers=headers,
                    json=payload
                )
                
                if response.status_code == 200:
                    result = response.json()
                    content = result['choices'][0]['message']['content']
                    
                    if "```json" in content:
                        json_str = content.split("```json")[1].split("```")[0].strip()
                    else:
                        json_str = content
                    
                    images = json.loads(json_str)
                    print(f"✅ 成功获取季节性图片")
                    return images
        except Exception as e:
            print(f"⚠️ 获取季节性图片失败: {e}")
        
        return {
            "spring": [{"url": "", "description": "春季"}],
            "summer": [{"url": "", "description": "夏季"}],
            "autumn": [{"url": "", "description": "秋季"}],
            "winter": [{"url": "", "description": "冬季"}]
        }
    
    def _validate_plant_details(self, details: Dict[str, Any]) -> None:
        """验证植物详细信息"""
        
        required = ['scientific_name', 'common_name', 'description', 'characteristics', 'care_guide']
        missing = [f for f in required if not details.get(f)]
        
        if missing:
            raise InvalidPlantDataError(f"缺少字段: {', '.join(missing)}")
        
        if len(details.get('characteristics', [])) < 3:
            raise InvalidPlantDataError("特征数至少 3 个")
        
        care = details.get('care_guide', {})
        required_care = ['sunlight', 'watering', 'soil', 'temperature']
        missing_care = [c for c in required_care if c not in care]
        
        if missing_care:
            raise InvalidPlantDataError(f"养护指南缺少: {', '.join(missing_care)}")
    
    async def _get_plant_by_scientific_name(self, scientific_name: str) -> Optional[Plant]:
        """获取现有植物记录"""
        result = await self.db.execute(
            select(Plant).where(Plant.scientific_name == scientific_name)
        )
        return result.scalar_one_or_none()
    
    async def _save_or_update_plant(
        self,
        scientific_name: str,
        common_name: str,
        plant_details: Dict[str, Any]
    ) -> Plant:
        """保存或更新植物"""
        
        existing = await self._get_plant_by_scientific_name(scientific_name)
        
        plant_data = {
            "scientific_name": scientific_name,
            "common_name": common_name,
            "family": plant_details.get("family"),
            "genus": plant_details.get("genus"),
            "species": plant_details.get("species"),
            "description": plant_details.get("description"),
            "characteristics": plant_details.get("characteristics", []),
            "care_info": plant_details.get("care_guide", {}),
            "plant_type": plant_details.get("plant_type"),
            "habitat": plant_details.get("habitat"),
            "origin": plant_details.get("origin"),
            "propagation_method": plant_details.get("propagation_method"),
            "common_pests": plant_details.get("common_pests", []),
            "height_range": plant_details.get("height_range"),
            "blooming_period": plant_details.get("blooming_period"),
            "toxicity": plant_details.get("toxicity", False),
            "toxicity_description": plant_details.get("toxicity_description"),
            "seasonal_images": plant_details.get("seasonal_images", {}),
            "is_verified": True,
            "updated_at": datetime.utcnow()
        }
        
        if existing:
            for key, value in plant_data.items():
                setattr(existing, key, value)
            await self.db.commit()
            return existing
        else:
            plant_data["is_featured"] = False
            plant_data["view_count"] = 0
            plant_data["identification_count"] = 0
            plant_data["created_at"] = datetime.utcnow()
            return await self.create(plant_data)
    
    def _plant_to_dict(self, plant: Plant) -> Dict[str, Any]:
        """转换为字典"""
        return {
            "id": str(plant.id),
            "scientific_name": plant.scientific_name,
            "common_name": plant.common_name,
            "family": plant.family,
            "genus": plant.genus,
            "species": plant.species,
            "description": plant.description,
            "characteristics": plant.characteristics or [],
            "care_guide": plant.care_info or {},
            "seasonal_images": plant.seasonal_images or {},
            "is_verified": plant.is_verified,
            "created_at": plant.created_at,
            "updated_at": plant.updated_at
        }
