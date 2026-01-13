// lib/models/user_model.dart

enum UserRole { admin, doctor, coder, auditor }

class User {
  final String id;
  final String name;
  final String email;
  final String username;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.doctor,
      ),
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() => 'User(id: $id, username: $username, role: ${role.name})';
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

class AuthResponse {
  final bool success;
  final User? user;
  final String? token;
  final String? refreshToken;
  final String? message;

  AuthResponse({
    required this.success,
    this.user,
    this.token,
    this.refreshToken,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      message: json['message'] as String?,
    );
  }
}
