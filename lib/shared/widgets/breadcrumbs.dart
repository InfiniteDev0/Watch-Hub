import 'package:flutter/material.dart';

class Breadcrumb extends StatelessWidget {
  final List<Widget> children;

  const Breadcrumb({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 4,
        spacing: 0,
        children: children,
      ),
    );
  }
}

class BreadcrumbItem extends StatelessWidget {
  final Widget child;
  const BreadcrumbItem({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class BreadcrumbLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbLink({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey, // Equivalent to text-muted-foreground
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class BreadcrumbPage extends StatelessWidget {
  final String label;
  const BreadcrumbPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black, // Equivalent to text-foreground
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class BreadcrumbSeparator extends StatelessWidget {
  final Widget? icon;
  const BreadcrumbSeparator({super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child:
          icon ?? const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
    );
  }
}

class BreadcrumbEllipsis extends StatelessWidget {
  const BreadcrumbEllipsis({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.more_horiz, size: 16, color: Colors.grey);
  }
}
