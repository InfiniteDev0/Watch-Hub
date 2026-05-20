import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/shared/components/help_drawer.dart';
import '../../logic/providers/cart_provider.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_error_state.dart';
import '../widgets/cart_item_row.dart';
import '../widgets/cart_order_summary.dart';
import '../widgets/cart_skeleton.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.initialLoading) return const CartSkeleton();

          if (cart.error != null && cart.cart == null) {
            return CartErrorState(
              message: cart.error!,
              onRetry: cart.fetchCart,
            );
          }

          if (cart.cart == null || cart.cart!.isEmpty) {
            return const CartEmptyState();
          }

          return _FilledCart(cart: cart);
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Shopping Bag',
        style: TextStyle(
          fontFamily: AppAssets.instrumentSerif,
          fontSize: 22,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            AppAssets.headset,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: () => showHelpDrawer(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// Thin assembly class — combines the item list with the order summary.
class _FilledCart extends StatelessWidget {
  final CartProvider cart;
  const _FilledCart({required this.cart});

  @override
  Widget build(BuildContext context) {
    final items = cart.cart!.items;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 28, color: Color(0xFFF0F0F0)),
            itemBuilder: (context, i) {
              final item = items[i];
              return CartItemRow(
                key: ValueKey(item.id),
                item: item,
                onQuantityChange: (qty) => cart.updateCartItem(item.id, qty),
                onRemove: () => cart.removeCartItem(item.id),
              );
            },
          ),
        ),
        CartOrderSummary(
          total: cart.cart!.total,
          onCheckout: () => context.push(AppRouter.checkout),
        ),
      ],
    );
  }
}
