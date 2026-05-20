import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/cart/data/models/cart_model.dart';

class CartItemRow extends StatefulWidget {
  final CartItemModel item;
  final void Function(int qty) onQuantityChange;
  final VoidCallback onRemove;

  const CartItemRow({
    super.key,
    required this.item,
    required this.onQuantityChange,
    required this.onRemove,
  });

  @override
  State<CartItemRow> createState() => _CartItemRowState();
}

class _CartItemRowState extends State<CartItemRow> {
  late int _qty;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _qty = widget.item.quantity;
  }

  @override
  void didUpdateWidget(covariant CartItemRow old) {
    super.didUpdateWidget(old);
    if (widget.item.id != old.item.id) {
      setState(() => _qty = widget.item.quantity);
    } else if (_debounce == null && widget.item.quantity != _qty) {
      setState(() => _qty = widget.item.quantity);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _increment() {
    setState(() => _qty++);
    _schedule();
  }

  void _decrement() {
    if (_qty <= 1) {
      widget.onRemove();
      return;
    }
    setState(() => _qty--);
    _schedule();
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _debounce = null;
      widget.onQuantityChange(_qty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localSubtotal = widget.item.price * _qty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.item.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: widget.item.imageUrl!,
                  width: 100,
                  height: 110,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(width: 16),

        // Details
        Expanded(
          child: SizedBox(
            height: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + trash icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onRemove,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ],
                ),

                // Subtitle (movement | material or SKU)
                if (widget.item.details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.item.details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],

                const Spacer(),

                // Price + stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${localSubtotal.toStringAsFixed(2)}USD',
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    _PillStepper(
                      quantity: _qty,
                      onIncrement: _increment,
                      onDecrement: _decrement,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
        width: 100,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.watch, color: Color(0xFFE0E0E0), size: 36),
      );
}

// ── Pill Stepper (private to this file) ──────────────────────────────────────

class _PillStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _PillStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillBtn(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          _PillBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PillBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, size: 15, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}
