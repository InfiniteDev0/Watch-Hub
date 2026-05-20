import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/shared/widgets/custom_alert_dialog.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

class SideMenuSheet extends StatelessWidget {
  final VoidCallback onClose;

  const SideMenuSheet({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final fullName = authProvider.currentUser?.fullName ?? '';
    final firstName = fullName.split(' ').first;

    final items = <(String, String)>[
      ('Orders', AppRouter.profileOrders),
      ('Personal Information', AppRouter.profilePersonalInfo),
      ('Addresses', AppRouter.profileAddresses),
      ('Payment', AppRouter.profilePayment),
      ('Saved Items', AppRouter.profileSavedItems),
      ('FAQ', AppRouter.faq),
      ('Contact Us', AppRouter.contact),
    ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Hi, $firstName',
              style: const TextStyle(
                fontFamily: AppAssets.instrumentSerif,
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Menu items
          ...items.map((item) => _buildMenuItem(context, item.$1, item.$2)),

          // Sign Out (red)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: InkWell(
              onTap: () => _confirmSignOut(context),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: AppAssets.instrumentSerif,
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: () {
          onClose();
          context.push(route);
        },
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    CustomAlertDialog.show(
      context: context,
      title: 'Sign out',
      description: 'Are you sure you want to sign out?',
      actionLabel: 'Sign out',
      actionVariant: ButtonVariant.destructive,
      onAction: () async {
        await context.read<AuthProvider>().signOut();
        // Router redirect handles navigation to onboarding
      },
    );
  }
}
