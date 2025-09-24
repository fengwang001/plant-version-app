/// 认证相关数据模型
import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

/// 用户登录请求
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// 用户注册请求
@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  @JsonKey(name: 'full_name')
  final String? fullName;

  const RegisterRequest({
    required this.email,
    required this.password,
    this.fullName,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

/// 游客登录请求
@JsonSerializable()
class GuestLoginRequest {
  @JsonKey(name: 'device_id')
  final String deviceId;
  @JsonKey(name: 'device_type')
  final String deviceType;

  const GuestLoginRequest({
    required this.deviceId,
    required this.deviceType,
  });

  factory GuestLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$GuestLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GuestLoginRequestToJson(this);
}

/// Apple登录请求
@JsonSerializable()
class AppleLoginRequest {
  @JsonKey(name: 'identity_token')
  final String identityToken;
  @JsonKey(name: 'authorization_code')
  final String? authorizationCode;
  @JsonKey(name: 'user_info')
  final AppleUserInfo? userInfo;

  const AppleLoginRequest({
    required this.identityToken,
    this.authorizationCode,
    this.userInfo,
  });

  factory AppleLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$AppleLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AppleLoginRequestToJson(this);
}

/// Apple用户信息
@JsonSerializable()
class AppleUserInfo {
  @JsonKey(name: 'given_name')
  final String? givenName;
  @JsonKey(name: 'family_name')
  final String? familyName;
  final String? email;

  const AppleUserInfo({
    this.givenName,
    this.familyName,
    this.email,
  });

  factory AppleUserInfo.fromJson(Map<String, dynamic> json) =>
      _$AppleUserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AppleUserInfoToJson(this);
}

/// Google登录请求
@JsonSerializable()
class GoogleLoginRequest {
  @JsonKey(name: 'id_token')
  final String idToken;
  @JsonKey(name: 'access_token')
  final String? accessToken;

  const GoogleLoginRequest({
    required this.idToken,
    this.accessToken,
  });

  factory GoogleLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleLoginRequestToJson(this);
}

/// 刷新令牌请求
@JsonSerializable()
class RefreshTokenRequest {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

/// 认证令牌响应
@JsonSerializable()
class AuthToken {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenToJson(this);

  /// 计算令牌过期时间
  DateTime get expiryTime => DateTime.now().add(Duration(seconds: expiresIn));

  /// 检查令牌是否即将过期（提前5分钟刷新）
  bool get shouldRefresh {
    final now = DateTime.now();
    final expiryTime = this.expiryTime;
    final refreshThreshold = expiryTime.subtract(const Duration(minutes: 5));
    return now.isAfter(refreshThreshold);
  }
}

/// 用户响应信息
@JsonSerializable()
class UserResponse {
  final String id;
  final String? email;
  final String? username;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? bio;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'user_type')
  final String userType;
  final String language;
  final String timezone;
  @JsonKey(name: 'identification_count')
  final int identificationCount;
  @JsonKey(name: 'video_generation_count')
  final int videoGenerationCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;

  const UserResponse({
    required this.id,
    this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    required this.isActive,
    required this.isVerified,
    required this.userType,
    required this.language,
    required this.timezone,
    required this.identificationCount,
    required this.videoGenerationCount,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  /// 显示名称
  String get displayName {
    if (fullName?.isNotEmpty == true) return fullName!;
    if (username?.isNotEmpty == true) return username!;
    if (email?.isNotEmpty == true) return email!.split('@')[0];
    return '用户${id.substring(0, 8)}';
  }

  /// 是否为游客用户
  bool get isGuest => email == null && username == null;

  /// 是否为付费用户
  bool get isPremium => userType == 'premium';
}

/// 认证结果
class AuthResult {
  final AuthToken token;
  final UserResponse user;

  const AuthResult({
    required this.token,
    required this.user,
  });
}

/// 认证状态
enum AuthStatus {
  /// 未认证
  unauthenticated,
  /// 已认证
  authenticated,
  /// 游客模式
  guest,
  /// 认证中
  authenticating,
  /// 认证失败
  failed,
}

/// 登录类型
enum LoginType {
  /// 邮箱登录
  email,
  /// Apple登录
  apple,
  /// Google登录
  google,
  /// 游客登录
  guest,
}
