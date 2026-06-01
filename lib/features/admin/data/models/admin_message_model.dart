class AdminMessageModel {
  final String id;
  final String fullName;
  final String email;
  final String subject;
  final String message;
  final String? userId;
  final bool isRead;
  final DateTime createdAt;

  const AdminMessageModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.subject,
    required this.message,
    this.userId,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminMessageModel.fromJson(Map<String, dynamic> j) =>
      AdminMessageModel(
        id: j['id'] as String,
        fullName: j['full_name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        subject: j['subject'] as String? ?? '',
        message: j['message'] as String? ?? '',
        userId: j['user_id'] as String?,
        isRead: j['is_read'] as bool? ?? false,
        createdAt:
            DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  AdminMessageModel copyWith({bool? isRead}) => AdminMessageModel(
        id: id,
        fullName: fullName,
        email: email,
        subject: subject,
        message: message,
        userId: userId,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
