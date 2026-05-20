import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

/// Hero banner — "Explore Our Popular Brands"
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(AppAssets.hero, fit: BoxFit.cover),

              // Top-left title
              const Positioned(
                top: 20,
                left: 20,
                child: Text(
                  'Explore Our \n Popular Brands',
                  style: TextStyle(
                    fontFamily: AppAssets.instrumentSerif,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),

              // Bottom-right Explore button
              Positioned(
                bottom: 16,
                right: 16,
                child: CustomButton(
                  text: 'Explore',
                  size: ButtonSize.lg,
                  onPressed: () => context.push(AppRouter.brands),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
