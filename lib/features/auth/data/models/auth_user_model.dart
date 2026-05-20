import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents an authenticated WatchHub user.
class AuthUserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final DateTime? createdAt;

  const AuthUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.role = 'customer',
    this.createdAt,
  });

  // ── Build from Supabase auth.User (basic info from JWT metadata) ──
  factory AuthUserModel.fromSupabaseUser(User user) {
    final meta = user.userMetadata ?? {};
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: meta['full_name'] as String? ?? '',
      phone: user.phone,
      avatarUrl: meta['avatar_url'] as String?,
      role: meta['role'] as String? ?? 'customer',
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  // ── Build from backend profile JSON ──────────────────────────────
  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'customer',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl,
        'role': role,
        'created_at': createdAt?.toIso8601String(),
      };

  AuthUserModel copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) {
    return AuthUserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      createdAt: createdAt,
    );
  }
}
