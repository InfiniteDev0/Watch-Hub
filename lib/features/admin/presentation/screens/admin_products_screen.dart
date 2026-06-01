import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_products_provider.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_product_form_screen.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_empty_state.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_search_bar.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_status_badge.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/shared/widgets/custom_alert_dialog.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductsProvider>().load();
    });
  }

  void _openForm({ProductModel? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminProductsProvider>(),
          child: AdminProductFormScreen(existing: product),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, ProductModel p) {
    CustomAlertDialog.show(
      context: ctx,
      title: 'Delete product?',
      description: '"${p.name}" will be permanently removed.',
      actionLabel: 'Delete',
      actionVariant: ButtonVariant.destructive,
      onAction: () async {
        final ok =
            await context.read<AdminProductsProvider>().delete(p.id);
        if (ok && ctx.mounted) {
          ToastHelper.showSuccess(ctx, 'Product deleted');
        } else if (ctx.mounted) {
          ToastHelper.showError(
            ctx,
            context.read<AdminProductsProvider>().error ?? 'Delete failed',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Products',
                      style: TextStyle(
                        fontFamily: AppAssets.instrumentSerif,
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  CustomButton(
                    text: 'Add',
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    size: ButtonSize.sm,
                    onPressed: () => _openForm(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search
              AdminSearchBar(
                hint: 'Search by name, brand, SKU…',
                onChanged: (q) =>
                    context.read<AdminProductsProvider>().search(q),
              ),
              const SizedBox(height: 16),
              // List
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<AdminProductsProvider>(
      builder: (context, p, _) {
        if (p.isLoading) return _skeleton();
        if (p.error != null && p.products.isEmpty) {
          return AdminErrorState(
            message: p.error!,
            onRetry: () => p.reload(),
          );
        }
        if (p.products.isEmpty) {
          return AdminEmptyState(
            icon: Icons.watch_outlined,
            message: 'No products yet.\nTap "Add" to create one.',
            actionLabel: 'Add Product',
            onAction: () => _openForm(),
          );
        }
        return RefreshIndicator(
          color: Colors.black,
          onRefresh: p.reload,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: p.products.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (ctx, i) =>
                _ProductTile(
                  product: p.products[i],
                  onEdit: () => _openForm(product: p.products[i]),
                  onDelete: () => _confirmDelete(ctx, p.products[i]),
                ),
          ),
        );
      },
    );
  }

  Widget _skeleton() => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Skeleton(width: 56, height: 56, borderRadius: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 160, height: 13),
                    const SizedBox(height: 6),
                    Skeleton(width: 100, height: 11),
                    const SizedBox(height: 6),
                    Skeleton(width: 70, height: 11),
                  ],
                ),
              ),
              Skeleton(width: 56, height: 24, borderRadius: 6),
            ],
          ),
        ),
      );
}

// ── Product tile ───────────────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.primaryImage != null
                  ? CachedNetworkImage(
                      imageUrl: product.primaryImage!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _placeholder(),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product.brandName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.brandName!,
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '£${(product.discountPrice ?? product.price).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AdminStatusBadge.stock(product.inStock),
            const SizedBox(width: 8),
            // Actions menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: Colors.black54),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.watch, color: Colors.white54, size: 24),
      );
}
