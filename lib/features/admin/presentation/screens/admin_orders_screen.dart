import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_orders_provider.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_order_detail_screen.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_empty_state.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_status_badge.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/features/admin/data/models/admin_order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrdersProvider>().load();
    });
  }

  void _openDetail(AdminOrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminOrdersProvider>(),
          child: AdminOrderDetailScreen(order: order),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Orders',
                style: const TextStyle(
                  fontFamily: AppAssets.instrumentSerif,
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            _FilterChips(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<AdminOrdersProvider>(
      builder: (context, p, _) {
        if (p.isLoading) return _skeleton();
        // Only surface a network-error state on first-load failure. Once data
        // has loaded, filtering to an empty subset should NOT look like an
        // error — and a failed status update must not poison the list view.
        if (p.loadError != null && !p.hasLoaded) {
          return AdminErrorState(message: p.loadError!, onRetry: p.reload);
        }
        if (p.orders.isEmpty) {
          final filter = p.statusFilter;
          return AdminEmptyState(
            icon: Icons.receipt_long_outlined,
            message: filter == null
                ? 'No orders yet.'
                : 'No $filter orders.',
          );
        }
        return RefreshIndicator(
          color: Colors.black,
          onRefresh: p.reload,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: p.orders.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (_, i) => _OrderTile(
              order: p.orders[i],
              onTap: () => _openDetail(p.orders[i]),
            ),
          ),
        );
      },
    );
  }

  Widget _skeleton() => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 140, height: 13),
                    const SizedBox(height: 6),
                    Skeleton(width: 100, height: 11),
                    const SizedBox(height: 6),
                    Skeleton(width: 70, height: 11),
                  ],
                ),
              ),
              Skeleton(width: 72, height: 24, borderRadius: 6),
            ],
          ),
        ),
      );
}

class _FilterChips extends StatelessWidget {
  static const _statuses = ['All', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];

  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AdminOrdersProvider>();
    final selected = prov.statusFilter;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = _statuses[i];
          final isAll = s == 'All';
          final active = isAll ? selected == null : selected == s;
          return GestureDetector(
            onTap: () => prov.setFilter(isAll ? null : s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? Colors.black : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAll ? 'All' : _cap(s),
                style: TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _OrderTile extends StatelessWidget {
  final AdminOrderModel order;
  final VoidCallback onTap;

  const _OrderTile({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final shortId = order.id.length > 8 ? '#${order.id.substring(0, 8).toUpperCase()}' : '#${order.id}';
    final date = _formatDate(order.createdAt);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortId,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '£${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 11,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AdminStatusBadge.orderStatus(order.status),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
