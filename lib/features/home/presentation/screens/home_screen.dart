import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/features/home/data/models/product_filter.dart';
import 'package:watch_hub/features/home/presentation/widgets/appbar.dart';
import 'package:watch_hub/features/home/presentation/widgets/filter_products.dart';
import 'package:watch_hub/features/home/presentation/widgets/filter_sheet.dart';
import 'package:watch_hub/features/home/presentation/widgets/hero_section.dart';
import 'package:watch_hub/features/home/presentation/widgets/product_grid_section.dart';
import 'package:watch_hub/features/home/presentation/widgets/search_sheet.dart';
import 'package:watch_hub/features/home/presentation/widgets/sidemenu_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMenuOpen = false;
  ProductFilter _filter = const ProductFilter.empty();

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        current: _filter,
        onApply: (f) => setState(() => _filter = f),
      ),
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    if (!_isMenuOpen) return;
    setState(() {
      _isMenuOpen = false;
    });
  }

  /// Push the search experience as its own page so it owns its keyboard
  /// lifecycle. Keeping it as an AnimatedPositioned overlay in the home
  /// Stack was what caused the home Scaffold to rebuild on every keyboard
  /// frame (MediaQuery viewInsets changes), producing the stuck-key feel.
  void _openSearch() {
    _closeMenu();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SearchSheet();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Compute once per build — used by both the side-menu offset and
    // the dismiss-tap region.
    final topPad = MediaQuery.paddingOf(context).top;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,

      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            // Larger cacheExtent so the grid below the fold is already
            // built when the user starts flinging.
            cacheExtent: 800,
            slivers: [
              // Fixed App Bar
              HomeAppBar(
                isMenuOpen: _isMenuOpen,
                onMenuToggle: _toggleMenu,
                onSearchOpen: _openSearch,
                onMenuClose: _closeMenu,
              ),

              // Hero banner
              const SliverToBoxAdapter(child: HeroSection()),

              // Filter header row
              SliverToBoxAdapter(
                child: FilterProducts(
                  onFilterTap: _openFilterSheet,
                  activeFilter: _filter,
                ),
              ),

              // Products from DB
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: ProductGridSection(filter: _filter),
                ),
              ),
            ],
          ),

          // Dark backdrop (closes sheet on tap)
          if (_isMenuOpen)
            Positioned.fill(
              top: topPad + 56,
              child: GestureDetector(
                onTap: _closeMenu,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withValues(alpha: 0.6)),
              ),
            ),

          // Side menu sheet — mounted only when needed so off-screen state
          // doesn't keep its subtree alive (and rebuilding on auth changes).
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            top: topPad + 56,
            bottom: 0,
            right: _isMenuOpen ? 0 : -screenWidth,
            width: screenWidth,
            child: _isMenuOpen
                ? SideMenuSheet(onClose: _closeMenu)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
