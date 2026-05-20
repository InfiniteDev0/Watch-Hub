import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/router/app_router.dart';

class HomeAppBar extends StatelessWidget {
  final bool isMenuOpen;
  final VoidCallback onMenuToggle;
  final VoidCallback onSearchOpen;
  final VoidCallback onMenuClose;

  const HomeAppBar({
    super.key,
    required this.isMenuOpen,
    required this.onMenuToggle,
    required this.onSearchOpen,
    required this.onMenuClose,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: GestureDetector(
        onTap: onMenuClose,
        child: const Text(
          'Watch Hub',
          style: TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            AppAssets.searchIcon,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: () {
            onMenuClose();
            onSearchOpen();
          },
        ),
        IconButton(
          icon: SvgPicture.asset(
            AppAssets.cartIcon,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: () {
            onMenuClose();
            context.push(AppRouter.cart);
          },
        ),
        IconButton(
          icon: SvgPicture.asset(
            isMenuOpen ? AppAssets.closeIcon : AppAssets.menu,
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: onMenuToggle,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
