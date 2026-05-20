import 'package:intl/intl.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String? title;
  final String? body;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    this.title,
    this.body,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String? ?? 'Anonymous',
        rating: json['rating'] as int,
        title: json['title'] as String?,
        body: json['body'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get formattedDate => DateFormat('MMM d, yyyy').format(createdAt);

  String get initials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return userName.isNotEmpty ? userName[0].toUpperCase() : '?';
  }
}

class ReviewSummary {
  final double average;
  final int total;
  final Map<int, int> distribution; // key: 1-5, value: count

  const ReviewSummary({
    required this.average,
    required this.total,
    required this.distribution,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    final raw = json['distribution'] as Map<String, dynamic>? ?? {};
    return ReviewSummary(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      total: json['total'] as int? ?? 0,
      distribution: {
        5: raw['5'] as int? ?? 0,
        4: raw['4'] as int? ?? 0,
        3: raw['3'] as int? ?? 0,
        2: raw['2'] as int? ?? 0,
        1: raw['1'] as int? ?? 0,
      },
    );
  }

  static ReviewSummary empty() => const ReviewSummary(
        average: 0,
        total: 0,
        distribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );

  double percentFor(int star) {
    if (total == 0) return 0;
    return (distribution[star] ?? 0) / total;
  }

  String get formattedAverage => average == 0 ? '—' : average.toStringAsFixed(1);
}
