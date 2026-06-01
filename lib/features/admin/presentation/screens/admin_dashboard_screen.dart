import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_brands_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_dashboard_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_messages_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_orders_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_products_provider.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_brand_form_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_product_form_screen.dart';
import 'package:watch_hub/features/admin/presentation/widgets/stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const AdminDashboardScreen({super.key, this.onNavigate});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().loadStats();
      // Warm messages provider so the badge appears + alert banner shows.
      context.read<AdminMessagesProvider>().load();
    });
  }

  void _newProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<AdminProductsProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<AdminBrandsProvider>(),
            ),
          ],
          child: const AdminProductFormScreen(),
        ),
      ),
    );
  }

  void _newBrand() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminBrandsProvider>(),
          child: const AdminBrandFormScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.black,
          onRefresh: () async {
            await Future.wait([
              context.read<AdminDashboardProvider>().loadStats(),
              context.read<AdminMessagesProvider>().reload(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontFamily: AppAssets.instrumentSerif,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Store overview',
                  style: TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Unread feedback alert ─────────────────────────
                Consumer<AdminMessagesProvider>(
                  builder: (_, p, __) {
                    if (p.unreadCount == 0) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _UnreadFeedbackBanner(
                        count: p.unreadCount,
                        onTap: () => widget.onNavigate?.call(6),
                      ),
                    );
                  },
                ),

                // ── Stats ─────────────────────────────────────────
                Consumer<AdminDashboardProvider>(
                  builder: (context, p, _) {
                    if (p.isLoading) return const StatsGridSkeleton();
                    if (p.error != null && p.stats == null) {
                      return _ErrorBanner(
                        message: p.error!,
                        onRetry: () =>
                            context.read<AdminDashboardProvider>().loadStats(),
                      );
                    }
                    return _DashboardStats(
                      totalUsers: p.stats?.totalUsers ?? 0,
                      totalOrders: p.stats?.totalOrders ?? 0,
                      totalProducts: p.stats?.totalProducts ?? 0,
                      totalRevenue: p.stats?.totalRevenue ?? 0,
                      onNavigate: widget.onNavigate,
                    );
                  },
                ),

                const SizedBox(height: 28),

                // ── Quick actions ─────────────────────────────────
                const Text(
                  'Quick actions',
                  style: TextStyle(
                    fontFamily: AppAssets.instrumentSerif,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.add_box_outlined,
                        label: 'New Product',
                        onTap: _newProduct,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.add_business_outlined,
                        label: 'New Brand',
                        onTap: _newBrand,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.pending_actions_outlined,
                        label: 'Pending Orders',
                        onTap: () {
                          context
                              .read<AdminOrdersProvider>()
                              .setFilter('pending');
                          widget.onNavigate?.call(2);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.star_outline,
                        label: 'Moderate Reviews',
                        onTap: () => widget.onNavigate?.call(5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardStats extends StatelessWidget {
  final int totalUsers;
  final int totalOrders;
  final int totalProducts;
  final double totalRevenue;
  final ValueChanged<int>? onNavigate;

  const _DashboardStats({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalRevenue,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RevenueCard(revenue: totalRevenue),
        const SizedBox(height: 6),
        StatCard(
          label: 'Orders',
          value: '$totalOrders',
          icon: Icons.receipt_long_outlined,
          onView: () => onNavigate?.call(2),
        ),
        StatCard(
          label: 'Products',
          value: '$totalProducts',
          icon: Icons.watch_outlined,
          onView: () => onNavigate?.call(1),
        ),
        StatCard(
          label: 'Users',
          value: '$totalUsers',
          icon: Icons.people_outline,
          onView: () => onNavigate?.call(3),
        ),
      ],
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final double revenue;

  const _RevenueCard({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up,
                  color: Color(0xFF34D399), size: 18),
              SizedBox(width: 8),
              Text(
                'Total Revenue',
                style: TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '£${revenue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: AppAssets.instrumentSerif,
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All-time, excluding cancelled orders',
            style: TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 11,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadFeedbackBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _UnreadFeedbackBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFE082)),
        ),
        child: Row(
          children: [
            const Icon(Icons.inbox_outlined,
                color: Color(0xFFF57F17), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count unread message${count == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF57F17),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Users have sent you feedback. Tap to review.',
                    style: TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 11,
                      color: Color(0xFFF57F17),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFF57F17)),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                color: Color(0xFFC62828),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFFC62828)),
            ),
          ),
        ],
      ),
    );
  }
}
