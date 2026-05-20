import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_provider.dart';
import 'package:watch_hub/features/admin/presentation/widgets/stat_card.dart';
// ignore: unused_import
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: AppAssets.instrumentSerif,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Overview of your store',
                style: TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              if (provider.isLoadingStats)
                const StatsGridSkeleton()
              else
                StatsGrid(
                  totalUsers: provider.stats?.totalUsers ?? 0,
                  totalOrders: provider.stats?.totalOrders ?? 0,
                  totalProducts: provider.stats?.totalProducts ?? 0,
                  totalRevenue: provider.stats?.totalRevenue ?? 0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
