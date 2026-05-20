import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

enum ButtonVariant {
  defaultVariant,
  outline,
  secondary,
  ghost,
  destructive,
  link,
}

enum ButtonSize { xs, sm, defaultSize, lg, icon }

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;
  final double? width;

  const CustomButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.defaultVariant,
    this.size = ButtonSize.defaultSize,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(isDarkMode),
        child: _buildContent(isDarkMode),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (isLoading) {
      return SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(isDarkMode)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          if (text != null) const SizedBox(width: 8),
        ],
        if (text != null)
          Text(
            text!,
            style: TextStyle(
              fontFamily: AppAssets.instrumentSans,
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
      ],
    );
  }

  ButtonStyle _getButtonStyle(bool isDarkMode) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(_getPadding()),
      minimumSize: WidgetStateProperty.all(Size(0, _getHeight())),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _getBgColor(isDarkMode).withOpacity(0.5);
        }
        return _getBgColor(isDarkMode);
      }),
      foregroundColor: WidgetStateProperty.all(_getTextColor(isDarkMode)),
      overlayColor: WidgetStateProperty.all(_getOverlayColor(isDarkMode)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: variant == ButtonVariant.outline
              ? BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12)
              : BorderSide.none,
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  // --- Style Helpers ---

  double _getHeight() {
    return switch (size) {
      ButtonSize.xs => 24,
      ButtonSize.sm => 32,
      ButtonSize.defaultSize => 40,
      ButtonSize.lg => 48,
      ButtonSize.icon => 40,
    };
  }

  EdgeInsets _getPadding() {
    if (size == ButtonSize.icon) return EdgeInsets.zero;
    return switch (size) {
      ButtonSize.xs => const EdgeInsets.symmetric(horizontal: 8),
      ButtonSize.sm => const EdgeInsets.symmetric(horizontal: 12),
      ButtonSize.defaultSize => const EdgeInsets.symmetric(horizontal: 16),
      ButtonSize.lg => const EdgeInsets.symmetric(horizontal: 24),
      ButtonSize.icon => EdgeInsets.zero,
    };
  }

  double _getFontSize() {
    return switch (size) {
      ButtonSize.xs => 12,
      ButtonSize.sm => 13,
      ButtonSize.defaultSize => 14,
      ButtonSize.lg => 16,
      ButtonSize.icon => 0,
    };
  }

  Color _getBgColor(bool isDarkMode) {
    switch (variant) {
      case ButtonVariant.defaultVariant:
        return isDarkMode ? Colors.white : Colors.black;
      case ButtonVariant.secondary:
        return isDarkMode ? Colors.white10 : const Color(0xFFF4F4F5);
      case ButtonVariant.destructive:
        return const Color(0xFFEF4444);
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
      case ButtonVariant.link:
        return Colors.transparent;
    }
  }

  Color _getTextColor(bool isDarkMode) {
    switch (variant) {
      case ButtonVariant.defaultVariant:
        return isDarkMode ? Colors.black : Colors.white;
      case ButtonVariant.secondary:
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return isDarkMode ? Colors.white : Colors.black87;
      case ButtonVariant.destructive:
        return Colors.white;
      case ButtonVariant.link:
        return Colors.blue;
    }
  }

  Color _getOverlayColor(bool isDarkMode) {
    return _getTextColor(isDarkMode).withOpacity(0.1);
  }
}
