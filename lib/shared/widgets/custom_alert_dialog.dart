import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

class CustomAlertDialog {
  static Future<void> show({
    required BuildContext context,
    Widget? media,
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
    String cancelLabel = "Cancel",
    ButtonVariant actionVariant = ButtonVariant.defaultVariant,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isDarkMode ? Colors.white10 : Colors.black12),
        ),
        // Layout inspired by your React AlertDialogHeader
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (media != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white10
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: media,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppAssets.instrumentSans,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        // Footer layout matching your React AlertDialogFooter
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: cancelLabel,
                  variant: ButtonVariant.outline,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: actionLabel,
                  variant: actionVariant,
                  onPressed: () {
                    Navigator.pop(context);
                    onAction();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
