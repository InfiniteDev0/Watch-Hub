import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

class ProductTags extends StatelessWidget {
  final List<String> tags;

  const ProductTags({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                t,
                style: TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
