class AdminUserModel {
  final String id;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  const AdminUserModel({
    required this.id,
    this.fullName,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory AdminUserModel.fromJson(Map<String, dynamic> j) => AdminUserModel(
        id: j['id'] as String,
        fullName: j['full_name'] as String?,
        phone: j['phone'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        role: j['role'] as String? ?? 'customer',
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
