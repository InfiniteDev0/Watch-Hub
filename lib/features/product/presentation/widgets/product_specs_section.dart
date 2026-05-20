import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';

class ProductSpecsSection extends StatefulWidget {
  final ProductModel product;

  const ProductSpecsSection({super.key, required this.product});

  @override
  State<ProductSpecsSection> createState() => _ProductSpecsSectionState();
}

class _ProductSpecsSectionState extends State<ProductSpecsSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final specs = <(String, String)>[
      if (p.movementType != null) ('Movement', p.movementType!),
      if (p.caseMaterial != null) ('Case Material', p.caseMaterial!),
      if (p.caseDiameterMm != null)
        ('Case Diameter', '${p.caseDiameterMm!.toStringAsFixed(1)} mm'),
      if (p.caseThicknessMm != null)
        ('Case Thickness', '${p.caseThicknessMm!.toStringAsFixed(1)} mm'),
      if (p.bandMaterial != null) ('Band Material', p.bandMaterial!),
      if (p.bandWidthMm != null)
        ('Band Width', '${p.bandWidthMm!.toStringAsFixed(1)} mm'),
      if (p.dialColor != null) ('Dial Color', p.dialColor!),
      if (p.crystalType != null) ('Crystal', p.crystalType!),
      if (p.waterResistanceM != null)
        ('Water Resistance', '${p.waterResistanceM} m'),
      if (p.lugWidthMm != null)
        ('Lug Width', '${p.lugWidthMm!.toStringAsFixed(1)} mm'),
    ];

    if (specs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Product Details',
                  style: TextStyle(
                    fontFamily: AppAssets.instrumentSerif,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  _expanded ? Icons.remove : Icons.add,
                  size: 20,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Column(
            children: specs.asMap().entries.map((e) {
              final isLast = e.key == specs.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(
                            color: Color(0xFFF0F0F0),
                            width: 1,
                          ),
                        ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        e.value.$1,
                        style: TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.value.$2,
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        const Divider(height: 1, color: Color(0xFFE5E5E5)),
        const SizedBox(height: 8),
      ],
    );
  }
}
