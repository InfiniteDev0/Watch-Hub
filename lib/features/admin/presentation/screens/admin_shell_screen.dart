import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_brands_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_dashboard_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_messages_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_orders_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_products_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_reviews_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_users_provider.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_brands_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_messages_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_reviews_screen.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _currentIndex = 0;

  void _goTo(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final repo = AdminRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider(repo)),
        ChangeNotifierProvider(create: (_) => AdminProductsProvider(repo)),
        ChangeNotifierProvider(create: (_) => AdminOrdersProvider(repo)),
        ChangeNotifierProvider(create: (_) => AdminUsersProvider(repo)),
        ChangeNotifierProvider(create: (_) => AdminBrandsProvider(repo)),
        ChangeNotifierProvider(create: (_) => AdminReviewsProvider(repo)),
        ChangeNotifierProvider(create: (_) => AdminMessagesProvider(repo)),
      ],
      child: _ShellView(
        currentIndex: _currentIndex,
        onTabTap: _goTo,
      ),
    );
  }
}

class _ShellView extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTap;

  const _ShellView({
    required this.currentIndex,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    final screens = [
      AdminDashboardScreen(onNavigate: onTabTap),
      const AdminProductsScreen(),
      const AdminOrdersScreen(),
      const AdminUsersScreen(),
      const AdminBrandsScreen(),
      const AdminReviewsScreen(),
      const AdminMessagesScreen(),
    ];

    return Scaffold(
      appBar: AdminAppBar(
        onSignOut: () => context.read<AuthProvider>().signOut(),
      ),
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: _AdminBottomNav(
        currentIndex: currentIndex,
        onTap: onTabTap,
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AdminBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<AdminMessagesProvider>().unreadCount;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey.shade400,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      selectedLabelStyle: const TextStyle(
        fontFamily: AppAssets.manrope,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: AppAssets.manrope,
      ),
      elevation: 8,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view_rounded),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.watch_outlined),
          activeIcon: Icon(Icons.watch),
          label: 'Products',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Users',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          activeIcon: Icon(Icons.storefront),
          label: 'Brands',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.star_outline),
          activeIcon: Icon(Icons.star),
          label: 'Reviews',
        ),
        BottomNavigationBarItem(
          icon: _BadgedIcon(icon: Icons.inbox_outlined, count: unread),
          activeIcon: _BadgedIcon(icon: Icons.inbox, count: unread),
          label: 'Feedback',
        ),
      ],
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int count;

  const _BadgedIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return Icon(icon);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          top: -4,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              count > 9 ? '9+' : '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
