import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

class WishlistErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WishlistErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFBDBDBD),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Try again',
                style: TextStyle(fontFamily: AppAssets.manrope),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
