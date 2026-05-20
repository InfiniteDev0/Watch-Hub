import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Orders',
                style: TextStyle(
                  fontFamily: AppAssets.instrumentSerif,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Text(
                    'Orders list coming soon',
                    style: TextStyle(
                      fontFamily: AppAssets.manrope,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
