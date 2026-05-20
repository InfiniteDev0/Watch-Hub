import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_provider.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_brands_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';

/// Root scaffold for the admin panel.
/// Provides [AdminProvider] to all child screens and keeps the
/// bottom nav bar in sync with the active section.
class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _currentIndex = 0;

  static const _screens = [
    AdminDashboardScreen(),
    AdminProductsScreen(),
    AdminOrdersScreen(),
    AdminUsersScreen(),
    AdminBrandsScreen(),
  ];

  static const _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.grid_view_outlined),
      activeIcon: Icon(Icons.grid_view_rounded),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.watch_outlined),
      activeIcon: Icon(Icons.watch),
      label: 'Products',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_outlined),
      activeIcon: Icon(Icons.receipt_long),
      label: 'Orders',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_outline),
      activeIcon: Icon(Icons.people),
      label: 'Users',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.storefront_outlined),
      activeIcon: Icon(Icons.storefront),
      label: 'Brands',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(AdminRepository()),
      child: Scaffold(
        appBar: AdminAppBar(
          onSignOut: () => context.read<AuthProvider>().signOut(),
        ),
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 11,
          ),
          elevation: 8,
          items: _navItems,
        ),
      ),
    );
  }
}
