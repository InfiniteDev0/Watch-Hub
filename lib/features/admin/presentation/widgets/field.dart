import 'package:flutter/material.dart';

enum FieldOrientation { vertical, horizontal }

/// The main Field wrapper
class Field extends StatelessWidget {
  final List<Widget> children;
  final FieldOrientation orientation;
  final bool isInvalid;
  final CrossAxisAlignment? crossAxisAlignment;

  const Field({
    super.key,
    required this.children,
    this.orientation = FieldOrientation.vertical,
    this.isInvalid = false,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final color = isInvalid ? Theme.of(context).colorScheme.error : null;

    if (orientation == FieldOrientation.horizontal) {
      return DefaultTextStyle(
        style: TextStyle(color: color),
        child: Row(
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
          children: children.map((child) => Expanded(child: child)).toList(),
        ),
      );
    }

    return DefaultTextStyle(
      style: TextStyle(color: color),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// Equivalent to FieldLabel / FieldTitle
class FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const FieldLabel(this.label, {super.key, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        isRequired ? '$label *' : label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

/// Equivalent to FieldDescription
class FieldDescription extends StatelessWidget {
  final String text;

  const FieldDescription(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).hintColor,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Equivalent to FieldError
class FieldError extends StatelessWidget {
  final String? error;

  const FieldError(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text(
        error!,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

/// Equivalent to FieldSeparator
class FieldSeparator extends StatelessWidget {
  final String? label;

  const FieldSeparator({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          if (label != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          if (label != null) const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
