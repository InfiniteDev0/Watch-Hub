import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/cart/logic/providers/cart_provider.dart';
import 'package:watch_hub/features/wishlist/logic/providers/wishlist_provider.dart';
import 'package:watch_hub/features/wishlist/presentation/widgets/wishlist_empty_state.dart';
import 'package:watch_hub/features/wishlist/presentation/widgets/wishlist_error_state.dart';
import 'package:watch_hub/features/wishlist/presentation/widgets/wishlist_item_row.dart';
import 'package:watch_hub/features/wishlist/presentation/widgets/wishlist_skeleton.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().fetchWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, _) {
          if (wishlist.initialLoading) return const WishlistSkeleton();

          if (wishlist.error != null && wishlist.items.isEmpty) {
            return WishlistErrorState(
              message: wishlist.error!,
              onRetry: wishlist.fetchWishlist,
            );
          }

          if (wishlist.items.isEmpty) return const WishlistEmptyState();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: wishlist.items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 28, color: Color(0xFFF0F0F0)),
            itemBuilder: (context, i) {
              final item = wishlist.items[i];
              return WishlistItemRow(
                key: ValueKey(item.id),
                item: item,
                onRemove: () async {
                  final ok =
                      await wishlist.removeFromWishlist(item.productId);
                  if (ok && context.mounted) {
                    ToastHelper.showInfo(context, 'Removed from saved items');
                  }
                },
                onMoveToCart: () async {
                  final cart = context.read<CartProvider>();
                  await wishlist.removeFromWishlist(item.productId);
                  // ignore: use_build_context_synchronously
                  await cart.addToCart(item.productId);
                  if (context.mounted) {
                    ToastHelper.showSuccess(context, 'Moved to shopping bag');
                  }
                },
              );
            },
          );
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
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Saved Items',
        style: TextStyle(
          fontFamily: AppAssets.instrumentSerif,
          fontSize: 22,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
