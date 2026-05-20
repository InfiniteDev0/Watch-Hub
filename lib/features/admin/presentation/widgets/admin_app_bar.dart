import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/shared/widgets/custom_alert_dialog.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

/// Top app bar shown across all admin screens.
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSignOut;

  const AdminAppBar({super.key, required this.onSignOut});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: const Text(
        'Watch Hub Admin',
        style: TextStyle(
          fontFamily: AppAssets.instrumentSerif,
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout, color: Colors.black, size: 22),
          onPressed: () => CustomAlertDialog.show(
            context: context,
            title: 'Are you absolutely sure?',
            description:
                'You will be signed out of your admin session and redirected to the login screen.',
            actionLabel: 'Sign out',
            actionVariant: ButtonVariant.destructive,
            onAction: onSignOut,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
