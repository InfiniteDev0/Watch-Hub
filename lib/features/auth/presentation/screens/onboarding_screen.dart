import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late VideoPlayerController _videoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(AppAssets.onboardingVideo)
      ..setVolume(0)
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoReady = true);
          _videoController.play();
        }
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Column(
        children: [
          // 1. Video Section (60% of screen height)
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                  bottom: Radius.circular(10),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: _videoReady
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // 2. Content Section (40% of screen height)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  // App Name
                  Text(
                    'Watch Hub',
                    style: TextStyle(
                      fontFamily: AppAssets.instrumentSerif,
                      fontSize: 42,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Log in or sign up to your WH account to access our watches',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppAssets.instrumentSans, // or standard sans
                      fontSize: 16,
                      height: 1.4,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),

                  const Spacer(),

                  // Log in Button
                  CustomButton(
                    text: 'Log in',
                    width: double.infinity,
                    size: ButtonSize.lg,
                    onPressed: () => context.push(AppRouter.login),
                  ),

                  const SizedBox(height: 12),

                  // Sign up Button
                  CustomButton(
                    text: 'Sign up',
                    width: double.infinity,
                    size: ButtonSize.lg,
                    variant: ButtonVariant.outline,
                    onPressed: () => context.push(AppRouter.signup),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
