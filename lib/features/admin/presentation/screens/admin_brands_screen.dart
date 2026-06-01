import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_brands_provider.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_brand_form_screen.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_empty_state.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/shared/widgets/custom_alert_dialog.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

class AdminBrandsScreen extends StatefulWidget {
  const AdminBrandsScreen({super.key});

  @override
  State<AdminBrandsScreen> createState() => _AdminBrandsScreenState();
}

class _AdminBrandsScreenState extends State<AdminBrandsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBrandsProvider>().load();
    });
  }

  void _openForm({BrandModel? brand}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminBrandsProvider>(),
          child: AdminBrandFormScreen(existing: brand),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, BrandModel brand) {
    CustomAlertDialog.show(
      context: ctx,
      title: 'Delete brand?',
      description: '"${brand.name}" will be permanently removed.',
      actionLabel: 'Delete',
      actionVariant: ButtonVariant.destructive,
      onAction: () async {
        final ok = await context.read<AdminBrandsProvider>().delete(brand.id);
        if (!ctx.mounted) return;
        if (ok) {
          ToastHelper.showSuccess(ctx, 'Brand deleted');
        } else {
          ToastHelper.showError(
            ctx,
            context.read<AdminBrandsProvider>().error ?? 'Delete failed',
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Brands',
                      style: const TextStyle(
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
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<AdminBrandsProvider>(
      builder: (context, p, _) {
        if (p.isLoading) return _skeleton();
        if (p.error != null && p.brands.isEmpty) {
          return AdminErrorState(
            message: p.error!,
            onRetry: p.reload,
          );
        }
        if (p.brands.isEmpty) {
          return AdminEmptyState(
            icon: Icons.storefront_outlined,
            message: 'No brands yet.\nTap "Add" to create one.',
            actionLabel: 'Add Brand',
            onAction: () => _openForm(),
          );
        }
        return RefreshIndicator(
          color: Colors.black,
          onRefresh: p.reload,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: p.brands.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (ctx, i) => _BrandTile(
              brand: p.brands[i],
              onEdit: () => _openForm(brand: p.brands[i]),
              onDelete: () => _confirmDelete(ctx, p.brands[i]),
            ),
          ),
        );
      },
    );
  }

  Widget _skeleton() => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              const Skeleton(width: 48, height: 48, borderRadius: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 120, height: 13),
                    const SizedBox(height: 6),
                    Skeleton(width: 180, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _BrandTile extends StatelessWidget {
  final BrandModel brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BrandTile({
    required this.brand,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: brand.logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: brand.logoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _logoPlaceholder(brand.name),
                      errorWidget: (_, __, ___) => _logoPlaceholder(brand.name),
                    )
                  : _logoPlaceholder(brand.name),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        brand.name,
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!brand.isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Inactive',
                            style: TextStyle(
                              fontFamily: AppAssets.manrope,
                              fontSize: 10,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (brand.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      brand.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholder(String name) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black38,
          ),
        ),
      );
}
