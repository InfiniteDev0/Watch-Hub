// Splash screen — shown while the auth session is validated on cold start
import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
      body: Stack(
        children: [
          // "Watch Hub" centered in the screen
          Center(
            child: Text(
              'Watch Hub',
              style: TextStyle(
                fontFamily: AppAssets.instrumentSerif,
                fontSize: 42,
                fontWeight: FontWeight.w400,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          // Spinner pinned near the bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDarkMode ? Colors.white54 : Colors.black38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
