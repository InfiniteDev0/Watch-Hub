import 'dart:math' as math;
import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 24.0, // Matching the 'size-4' small footprint
    this.color,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(); // This creates the 'animate-spin' effect
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        widget.color ?? (isDarkMode ? Colors.white : Colors.black);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: child,
              );
            },
            child: Icon(Icons.refresh, size: widget.size, color: iconColor),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.message!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
