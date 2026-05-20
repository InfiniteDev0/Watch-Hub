import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

class DropdownMenu extends StatelessWidget {
  final VoidCallback onClose;

  const DropdownMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E2E2), // Light grey matching image
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMenuItem(context, 'New Arrivals'),
            _buildMenuItem(context, 'Best Sellers'),
            _buildMenuItem(context, 'Collections'),
            _buildMenuItem(context, 'Men'),
            _buildMenuItem(context, 'Women'),
            _buildMenuItem(context, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        onClose();
        // Navigation logic here
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily:
                    AppAssets.instrumentSans, // Sans-serif matching image
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
