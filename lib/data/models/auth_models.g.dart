// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['full_name'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'full_name': instance.fullName,
    };

GuestLoginRequest _$GuestLoginRequestFromJson(Map<String, dynamic> json) =>
    GuestLoginRequest(
      deviceId: json['device_id'] as String,
      deviceType: json['device_type'] as String,
    );

Map<String, dynamic> _$GuestLoginRequestToJson(GuestLoginRequest instance) =>
    <String, dynamic>{
      'device_id': instance.deviceId,
      'device_type': instance.deviceType,
    };

AppleLoginRequest _$AppleLoginRequestFromJson(Map<String, dynamic> json) =>
    AppleLoginRequest(
      identityToken: json['identity_token'] as String,
      authorizationCode: json['authorization_code'] as String?,
      userInfo: json['user_info'] == null
          ? null
          : AppleUserInfo.fromJson(json['user_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppleLoginRequestToJson(AppleLoginRequest instance) =>
    <String, dynamic>{
      'identity_token': instance.identityToken,
      'authorization_code': instance.authorizationCode,
      'user_info': instance.userInfo,
    };

AppleUserInfo _$AppleUserInfoFromJson(Map<String, dynamic> json) =>
    AppleUserInfo(
      givenName: json['given_name'] as String?,
      familyName: json['family_name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$AppleUserInfoToJson(AppleUserInfo instance) =>
    <String, dynamic>{
      'given_name': instance.givenName,
      'family_name': instance.familyName,
      'email': instance.email,
    };

GoogleLoginRequest _$GoogleLoginRequestFromJson(Map<String, dynamic> json) =>
    GoogleLoginRequest(
      idToken: json['id_token'] as String,
      accessToken: json['access_token'] as String?,
    );

Map<String, dynamic> _$GoogleLoginRequestToJson(GoogleLoginRequest instance) =>
    <String, dynamic>{
      'id_token': instance.idToken,
      'access_token': instance.accessToken,
    };

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(refreshToken: json['refresh_token'] as String);

Map<String, dynamic> _$RefreshTokenRequestToJson(
  RefreshTokenRequest instance,
) => <String, dynamic>{'refresh_token': instance.refreshToken};

AuthToken _$AuthTokenFromJson(Map<String, dynamic> json) => AuthToken(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  tokenType: json['token_type'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
);

Map<String, dynamic> _$AuthTokenToJson(AuthToken instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'token_type': instance.tokenType,
  'expires_in': instance.expiresIn,
};

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
  id: json['id'] as String,
  email: json['email'] as String?,
  username: json['username'] as String?,
  fullName: json['full_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  bio: json['bio'] as String?,
  isActive: json['is_active'] as bool,
  isVerified: json['is_verified'] as bool,
  userType: json['user_type'] as String,
  language: json['language'] as String,
  timezone: json['timezone'] as String,
  identificationCount: (json['identification_count'] as num).toInt(),
  videoGenerationCount: (json['video_generation_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  lastLoginAt: json['last_login_at'] == null
      ? null
      : DateTime.parse(json['last_login_at'] as String),
);

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'is_active': instance.isActive,
      'is_verified': instance.isVerified,
      'user_type': instance.userType,
      'language': instance.language,
      'timezone': instance.timezone,
      'identification_count': instance.identificationCount,
      'video_generation_count': instance.videoGenerationCount,
      'created_at': instance.createdAt.toIso8601String(),
      'last_login_at': instance.lastLoginAt?.toIso8601String(),
    };
