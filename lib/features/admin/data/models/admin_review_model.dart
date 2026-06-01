class AdminReviewModel {
  final String id;
  final int rating;
  final String? title;
  final String? body;
  final DateTime createdAt;
  final String userId;
  final String productId;
  final String userName;
  final String productName;

  const AdminReviewModel({
    required this.id,
    required this.rating,
    this.title,
    this.body,
    required this.createdAt,
    required this.userId,
    required this.productId,
    required this.userName,
    required this.productName,
  });

  factory AdminReviewModel.fromJson(Map<String, dynamic> j) => AdminReviewModel(
        id: j['id'] as String,
        rating: j['rating'] as int? ?? 0,
        title: j['title'] as String?,
        body: j['body'] as String?,
        createdAt:
            DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
        userId: j['user_id'] as String? ?? '',
        productId: j['product_id'] as String? ?? '',
        userName: j['user_name'] as String? ?? 'Anonymous',
        productName: j['product_name'] as String? ?? 'Unknown',
      );
}
