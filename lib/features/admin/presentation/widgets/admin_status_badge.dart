import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

/// Colored pill badge for order status, user role, stock status, etc.
class AdminStatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const AdminStatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Factory for order status.
  factory AdminStatusBadge.orderStatus(String status) {
    final (bg, fg) = switch (status.toLowerCase()) {
      'pending' => (const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
      'processing' => (const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      'shipped' => (const Color(0xFFE8EAF6), const Color(0xFF283593)),
      'delivered' => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      'cancelled' => (const Color(0xFFFFEBEE), const Color(0xFFC62828)),
      _ => (const Color(0xFFF5F5F5), const Color(0xFF616161)),
    };
    return AdminStatusBadge(
      label: _cap(status),
      backgroundColor: bg,
      textColor: fg,
    );
  }

  /// Factory for user role.
  factory AdminStatusBadge.role(String role) {
    final isAdmin = role == 'admin';
    return AdminStatusBadge(
      label: _cap(role),
      backgroundColor:
          isAdmin ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
      textColor: isAdmin ? Colors.white : const Color(0xFF616161),
    );
  }

  /// Factory for in-stock / out-of-stock.
  factory AdminStatusBadge.stock(bool inStock) => AdminStatusBadge(
        label: inStock ? 'In Stock' : 'Out of Stock',
        backgroundColor:
            inStock ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        textColor:
            inStock ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
      );

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppAssets.manrope,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
