import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/orders/data/models/order_model.dart';
import 'package:watch_hub/features/orders/data/repositories/order_repository.dart';
import 'package:watch_hub/features/orders/logic/providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = OrderRepository();
      _order = await repo.fetchOrderById(widget.orderId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cancel Order',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await context.read<OrderProvider>().cancelOrder(widget.orderId);
    if (!mounted) return;
    if (ok) {
      // Refresh local detail to reflect new status
      await _loadOrder();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<OrderProvider>().error ?? 'Could not cancel order',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _order != null ? _order!.shortId : 'Order',
          style: const TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadOrder)
              : _OrderContent(order: _order!, onCancel: _cancelOrder),
    );
  }
}

// ── Main content ───────────────────────────────────────────────────

class _OrderContent extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onCancel;

  const _OrderContent({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final addr = order.shippingAddress;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status + date row ────────────────────────────────────
          Row(
            children: [
              _StatusBadge(label: order.statusLabel, color: order.statusColor),
              const Spacer(),
              Text(
                order.formattedDate,
                style: const TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Shipping address ─────────────────────────────────────
          const _SectionLabel('Shipping Address'),
          const SizedBox(height: 8),
          Text(
            addr['full_name'] as String? ?? '',
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            addr['street'] as String? ?? '',
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '${addr['city'] ?? ''}, ${addr['postal_code'] ?? ''}',
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            addr['country'] as String? ?? '',
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 28),

          // ── Items ─────────────────────────────────────────────────
          const _SectionLabel('Items'),
          const SizedBox(height: 12),
          ...order.items.map((item) => _OrderItemRow(item: item)),
          const Divider(height: 32, color: Color(0xFFF0F0F0)),

          // ── Total ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // ── Cancel button (pending only) ──────────────────────────
          if (order.isCancellable) ...[
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel Order',
                  style: TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Order item row ─────────────────────────────────────────────────

class _OrderItemRow extends StatelessWidget {
  final OrderItemModel item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.productImage != null
                ? Image.network(
                    item.productImage!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                  )
                : const _ImagePlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small helpers ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: AppAssets.manrope,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: Colors.black54,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppAssets.manrope,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFF5F5F5),
      child: const Icon(Icons.watch, color: Colors.black26, size: 28),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
