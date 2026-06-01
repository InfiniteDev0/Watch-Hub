import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/admin/data/models/admin_order_model.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_orders_provider.dart';

const _validStatuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];

class AdminOrderDetailScreen extends StatefulWidget {
  final AdminOrderModel order;
  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == _currentStatus) return;
    final prov = context.read<AdminOrdersProvider>();
    final ok = await prov.updateStatus(widget.order.id, newStatus);
    if (!mounted) return;
    if (ok) {
      setState(() => _currentStatus = newStatus);
      ToastHelper.showSuccess(context, 'Status updated');
    } else {
      ToastHelper.showError(context, prov.updateError ?? 'Update failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final shortId = order.id.length > 8
        ? '#${order.id.substring(0, 8).toUpperCase()}'
        : '#${order.id}';
    final isUpdating = context.watch<AdminOrdersProvider>().isUpdating;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          shortId,
          style: const TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Status section
          _sectionLabel('Order Status'),
          const SizedBox(height: 10),
          if (isUpdating)
            const LinearProgressIndicator(color: Colors.black)
          else
            _StatusSelector(
              current: _currentStatus,
              onSelect: _updateStatus,
            ),
          const SizedBox(height: 20),

          // Customer info
          _sectionLabel('Customer'),
          const SizedBox(height: 8),
          _infoRow('Name', order.customerName),
          if (order.shippingAddress != null) ...[
            const SizedBox(height: 16),
            _sectionLabel('Shipping Address'),
            const SizedBox(height: 8),
            _AddressBlock(address: order.shippingAddress!),
          ],
          const SizedBox(height: 20),

          // Items
          _sectionLabel('Items (${order.items.length})'),
          const SizedBox(height: 8),
          ...order.items.map((item) => _ItemRow(item: item)),
          const Divider(height: 32, color: Color(0xFFF0F0F0)),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '£${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Placed ${_formatDate(order.createdAt)}',
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 12,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: AppAssets.instrumentSerif,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      );

  Widget _infoRow(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                color: Colors.black45,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

class _StatusSelector extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const _StatusSelector({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _validStatuses.map((s) {
        final active = s == current;
        return GestureDetector(
          onTap: () => onSelect(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? Colors.black : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: active
                  ? null
                  : Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              _cap(s),
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _AddressBlock extends StatelessWidget {
  final Map<String, dynamic> address;

  const _AddressBlock({required this.address});

  @override
  Widget build(BuildContext context) {
    final parts = [
      address['line1'],
      address['line2'],
      address['city'],
      address['postcode'],
      address['country'],
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    return Text(
      parts.isEmpty ? 'No address provided' : parts,
      style: const TextStyle(
        fontFamily: AppAssets.manrope,
        fontSize: 13,
        color: Colors.black54,
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final AdminOrderItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.productImage != null
                ? CachedNetworkImage(
                    imageUrl: item.productImage!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholder(),
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '£${(item.priceAtPurchase * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.watch, color: Colors.white54, size: 20),
      );
}
