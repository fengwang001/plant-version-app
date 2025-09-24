class PlantIdentification {
  final String id;
  final String scientificName;
  final String commonName;
  final double confidence;
  final String? imageUrl;
  final int? imageWidth;
  final int? imageHeight;
  final List<PlantSuggestion>? suggestions;
  final String? userFeedback;
  final String? userNotes;
  final String identificationSource;
  final String processingStatus;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final PlantDetail? plantDetails;
  final String? description;
  final List<String> characteristics;
  final PlantCareInfo? careInfo;
  final DateTime identifiedAt;

  const PlantIdentification({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.confidence,
    this.imageUrl,
    this.imageWidth,
    this.imageHeight,
    this.suggestions,
    this.userFeedback,
    this.userNotes,
    required this.identificationSource,
    required this.processingStatus,
    this.latitude,
    this.longitude,
    this.locationName,
    this.plantDetails,
    this.description,
    required this.characteristics,
    this.careInfo,
    required this.identifiedAt,
  });

  /// 从本地JSON创建实例（兼容旧版本）
  factory PlantIdentification.fromJson(Map<String, dynamic> json) {
    return PlantIdentification(
      id: json['id'] as String,
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      imageWidth: json['imageWidth'] as int?,
      imageHeight: json['imageHeight'] as int?,
      suggestions: json['suggestions'] != null
          ? (json['suggestions'] as List)
              .map((item) => PlantSuggestion.fromJson(item))
              .toList()
          : null,
      userFeedback: json['userFeedback'] as String?,
      userNotes: json['userNotes'] as String?,
      identificationSource: json['identificationSource'] as String? ?? 'local',
      processingStatus: json['processingStatus'] as String? ?? 'completed',
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['locationName'] as String?,
      plantDetails: json['plantDetails'] != null
          ? PlantDetail.fromJson(json['plantDetails'])
          : null,
      description: json['description'] as String?,
      characteristics: json['characteristics'] != null 
          ? List<String>.from(json['characteristics'] as List)
          : [],
      careInfo: json['careInfo'] != null 
          ? PlantCareInfo.fromJson(json['careInfo'] as Map<String, dynamic>)
          : null,
      identifiedAt: DateTime.parse(json['identifiedAt'] as String),
    );
  }

  /// 从API响应创建实例
  factory PlantIdentification.fromApiJson(Map<String, dynamic> json) {
    return PlantIdentification(
      id: json['id'] as String,
      scientificName: json['scientific_name'] as String,
      commonName: json['common_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      imageWidth: json['image_width'] as int?,
      imageHeight: json['image_height'] as int?,
      suggestions: json['suggestions'] != null
          ? (json['suggestions'] as List)
              .map((item) => PlantSuggestion.fromApiJson(item))
              .toList()
          : null,
      userFeedback: json['user_feedback'] as String?,
      userNotes: json['user_notes'] as String?,
      identificationSource: json['identification_source'] as String,
      processingStatus: json['processing_status'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['location_name'] as String?,
      plantDetails: json['plant_details'] != null
          ? PlantDetail.fromJson(json['plant_details'])
          : null,
      description: json['plant_details']?['description'] as String?,
      characteristics: json['plant_details']?['characteristics'] != null 
          ? List<String>.from(json['plant_details']['characteristics'] as List)
          : [],
      careInfo: json['plant_details']?['care_info'] != null 
          ? PlantCareInfo.fromJson(json['plant_details']['care_info'])
          : null,
      identifiedAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scientificName': scientificName,
      'commonName': commonName,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'suggestions': suggestions?.map((s) => s.toJson()).toList(),
      'userFeedback': userFeedback,
      'userNotes': userNotes,
      'identificationSource': identificationSource,
      'processingStatus': processingStatus,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'plantDetails': plantDetails?.toJson(),
      'description': description,
      'characteristics': characteristics,
      'careInfo': careInfo?.toJson(),
      'identifiedAt': identifiedAt.toIso8601String(),
    };
  }
}

class PlantCareInfo {
  final String sunlight;
  final String watering;
  final String soil;
  final String temperature;
  final List<String> tips;

  const PlantCareInfo({
    required this.sunlight,
    required this.watering,
    required this.soil,
    required this.temperature,
    required this.tips,
  });

  factory PlantCareInfo.fromJson(Map<String, dynamic> json) {
    return PlantCareInfo(
      sunlight: json['sunlight'] as String,
      watering: json['watering'] as String,
      soil: json['soil'] as String,
      temperature: json['temperature'] as String,
      tips: List<String>.from(json['tips'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sunlight': sunlight,
      'watering': watering,
      'soil': soil,
      'temperature': temperature,
      'tips': tips,
    };
  }
}

class IdentificationResult {
  final String requestId;
  final List<PlantIdentification> suggestions;
  final bool isSuccess;
  final String? errorMessage;

  const IdentificationResult({
    required this.requestId,
    required this.suggestions,
    required this.isSuccess,
    this.errorMessage,
  });

  factory IdentificationResult.fromJson(Map<String, dynamic> json) {
    return IdentificationResult(
      requestId: json['requestId'] as String,
      suggestions: (json['suggestions'] as List)
          .map((item) => PlantIdentification.fromJson(item as Map<String, dynamic>))
          .toList(),
      isSuccess: json['isSuccess'] as bool,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'suggestions': suggestions.map((item) => item.toJson()).toList(),
      'isSuccess': isSuccess,
      'errorMessage': errorMessage,
    };
  }
}

/// 植物识别建议
class PlantSuggestion {
  final String scientificName;
  final String commonName;
  final double confidence;
  final Map<String, dynamic>? plantDetails;

  const PlantSuggestion({
    required this.scientificName,
    required this.commonName,
    required this.confidence,
    this.plantDetails,
  });

  factory PlantSuggestion.fromJson(Map<String, dynamic> json) {
    return PlantSuggestion(
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      plantDetails: json['plantDetails'] as Map<String, dynamic>?,
    );
  }

  factory PlantSuggestion.fromApiJson(Map<String, dynamic> json) {
    return PlantSuggestion(
      scientificName: json['scientific_name'] as String,
      commonName: json['common_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      plantDetails: json['plant_details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scientificName': scientificName,
      'commonName': commonName,
      'confidence': confidence,
      'plantDetails': plantDetails,
    };
  }
}

/// 植物详情（从API服务中移动到这里以避免循环依赖）
class PlantDetail {
  final String id;
  final String scientificName;
  final String commonName;
  final String? family;
  final String? genus;
  final String? species;
  final String? description;
  final List<String>? characteristics;
  final PlantCareInfo? careInfo;
  final String? primaryImageUrl;
  final List<String>? imageUrls;
  final String? plantType;
  final String? habitat;
  final String? origin;
  final int identificationCount;
  final int viewCount;
  final bool isVerified;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const PlantDetail({
    required this.id,
    required this.scientificName,
    required this.commonName,
    this.family,
    this.genus,
    this.species,
    this.description,
    this.characteristics,
    this.careInfo,
    this.primaryImageUrl,
    this.imageUrls,
    this.plantType,
    this.habitat,
    this.origin,
    required this.identificationCount,
    required this.viewCount,
    required this.isVerified,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory PlantDetail.fromJson(Map<String, dynamic> json) {
    return PlantDetail(
      id: json['id'] as String,
      scientificName: json['scientific_name'] as String,
      commonName: json['common_name'] as String,
      family: json['family'] as String?,
      genus: json['genus'] as String?,
      species: json['species'] as String?,
      description: json['description'] as String?,
      characteristics: json['characteristics'] != null 
          ? List<String>.from(json['characteristics'])
          : null,
      careInfo: json['care_info'] != null 
          ? PlantCareInfo.fromJson(json['care_info'])
          : null,
      primaryImageUrl: json['primary_image_url'] as String?,
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'])
          : null,
      plantType: json['plant_type'] as String?,
      habitat: json['habitat'] as String?,
      origin: json['origin'] as String?,
      identificationCount: json['identification_count'] as int,
      viewCount: json['view_count'] as int,
      isVerified: json['is_verified'] as bool,
      isFeatured: json['is_featured'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scientific_name': scientificName,
      'common_name': commonName,
      'family': family,
      'genus': genus,
      'species': species,
      'description': description,
      'characteristics': characteristics,
      'care_info': careInfo?.toJson(),
      'primary_image_url': primaryImageUrl,
      'image_urls': imageUrls,
      'plant_type': plantType,
      'habitat': habitat,
      'origin': origin,
      'identification_count': identificationCount,
      'view_count': viewCount,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
