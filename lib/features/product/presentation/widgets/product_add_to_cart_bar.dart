import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/cart/logic/providers/cart_provider.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';

class ProductAddToCartBar extends StatelessWidget {
  final ProductModel product;

  const ProductAddToCartBar({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: Consumer<CartProvider>(
            builder: (context, cart, _) {
              return ElevatedButton(
                onPressed: product.inStock
                    ? () async {
                        await cart.addToCart(product.id);
                        if (!context.mounted) return;

                        if (cart.error == null) {
                          ToastHelper.showSuccess(
                            context,
                            'Added to shopping bag',
                          );
                        } else {
                          ToastHelper.showError(context, cart.error!);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                child: cart.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        product.inStock
                            ? 'Add to Shopping Bag'
                            : 'Out of Stock',
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
