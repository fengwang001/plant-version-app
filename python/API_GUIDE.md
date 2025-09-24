# PlantVision API 调用指南

## 🔍 植物识别相关API

### 1. 获取最近识别列表

**接口**: `GET /api/v1/plants/identifications`

**说明**: 获取用户的植物识别历史记录（最近识别列表）

**请求参数**:
- `skip`: 跳过数量 (默认: 0)
- `limit`: 返回数量 (默认: 20, 最大: 100)

**请求头**:
```
Authorization: Bearer <access_token>
```

**响应示例**:
```json
[
  {
    "id": "identification_id",
    "scientific_name": "Rosa damascena",
    "common_name": "大马士革玫瑰",
    "confidence": 0.95,
    "image_url": "/storage/user_id/plant_image/rose_001.jpg",
    "image_width": 1024,
    "image_height": 768,
    "suggestions": [
      {
        "scientific_name": "Rosa damascena",
        "common_name": "大马士革玫瑰",
        "confidence": 0.95,
        "plant_details": {
          "family": "蔷薇科",
          "genus": "蔷薇属",
          "origin": "中东地区"
        }
      }
    ],
    "user_feedback": null,
    "user_notes": null,
    "identification_source": "plant.id",
    "processing_status": "completed",
    "latitude": 39.9042,
    "longitude": 116.4074,
    "location_name": "北京市朝阳区",
    "plant_details": {
      "id": "plant_id",
      "scientific_name": "Rosa damascena",
      "common_name": "大马士革玫瑰",
      "family": "蔷薇科",
      "genus": "蔷薇属",
      "species": "大马士革玫瑰",
      "description": "大马士革玫瑰是一种古老的玫瑰品种...",
      "plant_type": "灌木",
      "habitat": "温带地区",
      "origin": "中东地区",
      "identification_count": 156,
      "view_count": 2340,
      "is_verified": true,
      "is_featured": true,
      "created_at": "2025-09-19T12:00:00Z",
      "updated_at": "2025-09-19T12:00:00Z"
    },
    "created_at": "2025-09-19T12:00:00Z",
    "updated_at": "2025-09-19T12:00:00Z"
  }
]
```

### 2. 植物识别

**接口**: `POST /api/v1/plants/identify`

**说明**: 上传植物图片进行识别

**请求头**:
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**请求参数**:
- `file`: 植物图片文件 (支持 JPEG, PNG, WebP，最大 10MB)
- `latitude`: 拍摄位置纬度（可选）
- `longitude`: 拍摄位置经度（可选）
- `location_name`: 位置名称（可选）

**响应**: 同上面的识别记录格式

### 3. 识别详情

**接口**: `GET /api/v1/plants/identifications/{identification_id}`

**说明**: 获取特定植物识别记录的详情

**请求头**:
```
Authorization: Bearer <access_token>
```

**响应**: 单个识别记录详情

## 🌿 植物信息相关API（无需认证）

### 1. 植物搜索

**接口**: `GET /api/v1/plants/`

**请求参数**:
- `q`: 搜索关键词
- `skip`: 跳过数量 (默认: 0)
- `limit`: 返回数量 (默认: 20)
- `verified_only`: 只显示已验证植物 (默认: true)

**响应示例**:
```json
{
  "plants": [
    {
      "id": "plant_id",
      "scientific_name": "Rosa damascena",
      "common_name": "大马士革玫瑰",
      "primary_image_url": null,
      "identification_count": 156
    }
  ],
  "total": 1,
  "has_more": false
}
```

### 2. 植物详情

**接口**: `GET /api/v1/plants/{plant_id}`

**响应**: 完整植物信息

### 3. 特色植物

**接口**: `GET /api/v1/plants/featured/list`

**请求参数**:
- `limit`: 返回数量 (默认: 10)

### 4. 热门植物

**接口**: `GET /api/v1/plants/popular/list`

**请求参数**:
- `limit`: 返回数量 (默认: 10)

## 📱 前端调用示例

### JavaScript/TypeScript

```javascript
// 获取最近识别列表
async function getRecentIdentifications(token, skip = 0, limit = 10) {
  const response = await fetch(`/api/v1/plants/identifications?skip=${skip}&limit=${limit}`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  if (!response.ok) {
    throw new Error('Failed to fetch identifications');
  }
  
  return await response.json();
}

// 植物识别
async function identifyPlant(token, imageFile, location = null) {
  const formData = new FormData();
  formData.append('file', imageFile);
  
  if (location) {
    formData.append('latitude', location.latitude);
    formData.append('longitude', location.longitude);
    formData.append('location_name', location.name);
  }
  
  const response = await fetch('/api/v1/plants/identify', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`
    },
    body: formData
  });
  
  if (!response.ok) {
    throw new Error('Plant identification failed');
  }
  
  return await response.json();
}

// 植物搜索
async function searchPlants(query, skip = 0, limit = 20) {
  const response = await fetch(`/api/v1/plants/?q=${encodeURIComponent(query)}&skip=${skip}&limit=${limit}`);
  
  if (!response.ok) {
    throw new Error('Search failed');
  }
  
  return await response.json();
}
```

### Flutter/Dart

```dart
// 获取最近识别列表
Future<List<PlantIdentification>> getRecentIdentifications({
  required String token,
  int skip = 0,
  int limit = 10,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/plants/identifications?skip=$skip&limit=$limit'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => PlantIdentification.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load identifications');
  }
}

// 植物识别
Future<PlantIdentification> identifyPlant({
  required String token,
  required File imageFile,
  double? latitude,
  double? longitude,
  String? locationName,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/api/v1/plants/identify'),
  );
  
  request.headers['Authorization'] = 'Bearer $token';
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
  
  if (latitude != null) request.fields['latitude'] = latitude.toString();
  if (longitude != null) request.fields['longitude'] = longitude.toString();
  if (locationName != null) request.fields['location_name'] = locationName;
  
  final response = await request.send();
  final responseBody = await response.stream.bytesToString();
  
  if (response.statusCode == 200) {
    return PlantIdentification.fromJson(json.decode(responseBody));
  } else {
    throw Exception('Plant identification failed');
  }
}
```

## 📊 测试数据状态

✅ **已添加的测试数据**:
- 5 个植物识别记录
- 测试用户: `testuser` (email: test@example.com)
- 包含不同时间点的识别记录
- 包含地理位置信息
- 包含置信度和候选结果
- 涵盖多种植物类型（玫瑰、薰衣草、芦荟等）

## 🚀 部署和启动

1. 启动后端服务:
```bash
cd python
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

2. API文档地址: `http://localhost:8000/docs`

3. 健康检查: `http://localhost:8000/health`

现在您的最近识别列表API已经有数据了，可以正常调用获取识别历史记录！🎉
