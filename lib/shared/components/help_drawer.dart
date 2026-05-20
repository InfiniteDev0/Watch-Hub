import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

void showHelpDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white, // As requested
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const HelpDrawer(),
  );
}

class HelpDrawer extends StatelessWidget {
  const HelpDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Contact Us',
            style: TextStyle(
              fontFamily: AppAssets.instrumentSerif,
              fontSize: 28,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _buildActionItem(
            title: 'Send an Email to Customer Care',
            iconPath: AppAssets.messageCircleMore,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            title: 'Call Our Customer Care',
            iconPath: AppAssets.phoneForwarded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111), // dark button background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white, // internal icon color
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: AppAssets
                      .manrope, // Assuming manrope or sans for clear text
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
