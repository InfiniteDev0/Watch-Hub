import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

class WishlistEmptyState extends StatelessWidget {
  const WishlistEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppAssets.bagSmile,
              width: 96,
              height: 96,
              colorFilter: const ColorFilter.mode(
                Color(0xFFBDBDBD),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Saved Items Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppAssets.instrumentSerif,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the heart icon on any watch to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 14,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
