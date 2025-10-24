class Plant {
  final String id;
  final String scientificName;
  final String commonName;
  final String? family;
  final String? genus;
  final String? species;
  final String? description;
  final List<dynamic>? characteristics;
  final List<Map<String, dynamic>>? careInfo;
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

  const Plant({
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

  /// 从API JSON创建实例
  factory Plant.fromApiJson(Map<String, dynamic> json) {
    print( '🌿 解析植物数据: $json' );
    return Plant(
      id: json['id'] as String,
      scientificName: json['scientific_name'] as String,
      commonName: json['common_name'] as String,
      family: json['family'] as String?,
      genus: json['genus'] as String?,
      species: json['species'] as String?,
      description: json['description'] as String?,
      characteristics: json['characteristics'] as List<dynamic>?,
      // careInfo: json['care_info'] as List<Map<String, dynamic>>?,
      primaryImageUrl: json['primary_image_url'] as String?,
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls']) 
          : null,
      plantType: json['plant_type'] as String?,
      habitat: json['habitat'] as String?,
      origin: json['origin'] as String?,
      identificationCount: json['identification_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为JSON
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
      // 'care_info': careInfo,
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

  /// 获取显示名称（优先显示常用名称）
  String get displayName => commonName.isNotEmpty ? commonName : scientificName;

  /// 获取简短描述
  String get shortDescription {
    if (description == null || description!.isEmpty) {
      return '$scientificName 是一种${family ?? '未知科'}植物。';
    }
    
    if (description!.length <= 100) {
      return description!;
    }
    
    return '${description!.substring(0, 97)}...';
  }

  /// 获取主要特征
  // List<String> get mainCharacteristics {
  //   if (characteristics == null) return [];
    
  //   final List<String> features = [];
  //   characteristics!.forEach((key, value) {
  //     if (value != null && value.toString().isNotEmpty) {
  //       features.add('$key: $value');
  //     }
  //   });
    
  //   return features.take(3).toList(); // 只返回前3个特征
  // }

  /// 获取护理要点
  // List<String> get carePoints {
  //   if (careInfo == null) return [];
    
  //   final List<String> points = [];
  //   careInfo!.forEach((key, value) {
  //     if (value != null && value.toString().isNotEmpty) {
  //       points.add('$key: $value');
  //     }
  //   });
    
  //   return points;
  // }

  /// 是否有图片
  bool get hasImage => primaryImageUrl != null && primaryImageUrl!.isNotEmpty;

  /// 获取所有图片URL
  List<String> get allImageUrls {
    final List<String> urls = [];
    if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty) {
      urls.add(primaryImageUrl!);
    }
    if (imageUrls != null) {
      urls.addAll(imageUrls!);
    }
    return urls.toSet().toList(); // 去重
  }

  @override
  String toString() {
    return 'Plant{id: $id, commonName: $commonName, scientificName: $scientificName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
