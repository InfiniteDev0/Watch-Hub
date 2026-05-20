/// Simple model for dashboard summary stats returned by the backend.
class AdminStatsModel {
  final int totalUsers;
  final int totalOrders;
  final int totalProducts;
  final double totalRevenue;

  const AdminStatsModel({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalRevenue,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['total_users'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
