import 'package:flutter/material.dart';

enum CardSize { defaultSize, sm }

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardSize size;
  final Color? backgroundColor;
  final double? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.size = CardSize.defaultSize,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Determine padding based on size
    final verticalPadding = size == CardSize.sm ? 12.0 : 16.0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: child,
      ),
    );
  }
}

class CardHeader extends StatelessWidget {
  final Widget title;
  final Widget? description;
  final Widget? action;
  final CardSize size;
  final bool hasBorderBottom;

  const CardHeader({
    super.key,
    required this.title,
    this.description,
    this.action,
    this.size = CardSize.defaultSize,
    this.hasBorderBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = size == CardSize.sm ? 12.0 : 16.0;
    final bottomPadding = hasBorderBottom
        ? (size == CardSize.sm ? 12.0 : 16.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        border: hasBorderBottom
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: size == CardSize.sm ? 14 : 16,
                  ),
                  child: title,
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    child: description!,
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class CardContent extends StatelessWidget {
  final Widget child;
  final CardSize size;

  const CardContent({
    super.key,
    required this.child,
    this.size = CardSize.defaultSize,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = size == CardSize.sm ? 12.0 : 16.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: child,
    );
  }
}

class CardFooter extends StatelessWidget {
  final Widget child;
  final CardSize size;

  const CardFooter({
    super.key,
    required this.child,
    this.size = CardSize.defaultSize,
  });

  @override
  Widget build(BuildContext context) {
    final padding = size == CardSize.sm ? 12.0 : 16.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: child,
    );
  }
}
