class User {
  final String id;
  final String? email;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final bool isActive;
  final bool isVerified;
  final String? appleId;
  final String? googleId;
  final String? deviceId;
  final String? deviceType;
  final String? deviceToken;
  final String language;
  final String timezone;
  final int identificationCount;
  final int videoGenerationCount;
  final DateTime? lastLoginAt;
  final DateTime? lastActiveAt;
  final String userType;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;

  User({
    required this.id,
    this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    required this.isActive,
    required this.isVerified,
    this.appleId,
    this.googleId,
    this.deviceId,
    this.deviceType,
    this.deviceToken,
    required this.language,
    required this.timezone,
    required this.identificationCount,
    required this.videoGenerationCount,
    this.lastLoginAt,
    this.lastActiveAt,
    required this.userType,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      isActive: json['is_active'] == 1,
      isVerified: json['is_verified'] == 1,
      appleId: json['apple_id'],
      googleId: json['google_id'],
      deviceId: json['device_id'],
      deviceType: json['device_type'],
      deviceToken: json['device_token'],
      language: json['language'] ?? 'en',
      timezone: json['timezone'] ?? 'UTC',
      identificationCount: json['identification_count'] ?? 0,
      videoGenerationCount: json['video_generation_count'] ?? 0,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at']) 
          : null,
      lastActiveAt: json['last_active_at'] != null 
          ? DateTime.parse(json['last_active_at']) 
          : null,
      userType: json['user_type'] ?? 'free',
      bio: json['bio'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isDeleted: json['is_deleted'] == 1,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_active': isActive ? 1 : 0,
      'is_verified': isVerified ? 1 : 0,
      'apple_id': appleId,
      'google_id': googleId,
      'device_id': deviceId,
      'device_type': deviceType,
      'device_token': deviceToken,
      'language': language,
      'timezone': timezone,
      'identification_count': identificationCount,
      'video_generation_count': videoGenerationCount,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'user_type': userType,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // 创建User实例的便捷方法
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    bool? isActive,
    bool? isVerified,
    String? appleId,
    String? googleId,
    String? deviceId,
    String? deviceType,
    String? deviceToken,
    String? language,
    String? timezone,
    int? identificationCount,
    int? videoGenerationCount,
    DateTime? lastLoginAt,
    DateTime? lastActiveAt,
    String? userType,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      appleId: appleId ?? this.appleId,
      googleId: googleId ?? this.googleId,
      deviceId: deviceId ?? this.deviceId,
      deviceType: deviceType ?? this.deviceType,
      deviceToken: deviceToken ?? this.deviceToken,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      identificationCount: identificationCount ?? this.identificationCount,
      videoGenerationCount: videoGenerationCount ?? this.videoGenerationCount,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      userType: userType ?? this.userType,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}