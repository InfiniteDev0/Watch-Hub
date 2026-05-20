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
  bool _isSearchOpen = false;
  final FocusNode _searchFocusNode = FocusNode();
  ProductFilter _filter = const ProductFilter.empty();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

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
    setState(() {
      _isMenuOpen = false;
    });
  }

  void _openSearch() {
    setState(() {
      _isSearchOpen = true;
    });
    // Delay focus until the animation starts so the keyboard appears with the sheet
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,

      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
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
              top: MediaQuery.of(context).padding.top + 56, // below the appbar
              child: GestureDetector(
                onTap: _closeMenu,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
            ),

          // Side menu sheet
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: MediaQuery.of(context).padding.top + 56,
            bottom: 0,
            right: _isMenuOpen ? 0 : -(MediaQuery.of(context).size.width),
            width: MediaQuery.of(context).size.width,
            child: SideMenuSheet(onClose: _closeMenu),
          ),

          // Search Sheet
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            left: 0,
            right: 0,
            top: _isSearchOpen ? 0 : MediaQuery.of(context).size.height,
            bottom: _isSearchOpen ? 0 : -(MediaQuery.of(context).size.height),
            child: SearchSheet(
              onClose: _closeSearch,
              focusNode: _searchFocusNode,
            ),
          ),
        ],
      ),
    );
  }
}
