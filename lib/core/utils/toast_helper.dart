import 'package:flutter/material.dart';

class ToastHelper {
  ToastHelper._();

  static void showSuccess(BuildContext context, String message) {
    _showCustomToast(
      context,
      message,
      icon: Icons.check_circle_outline_rounded,
      iconColor: Colors.green,
    );
  }

  static void showError(BuildContext context, String message) {
    _showCustomToast(
      context,
      message,
      icon: Icons.error_outline_rounded,
      iconColor: Colors.redAccent,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showCustomToast(
      context,
      message,
      icon: Icons.info_outline_rounded,
      iconColor: Colors.blue,
    );
  }

  static void _showCustomToast(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color iconColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Sonner-style colors
    final bgColor = isDarkMode ? const Color(0xFF18181B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF18181B);
    final borderColor = isDarkMode
        ? Colors.white10
        : Colors.black.withOpacity(0.05);

    ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing toasts
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        // Position at the very top, below the status bar
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top -
              100,
          left: 16,
          right: 16,
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
