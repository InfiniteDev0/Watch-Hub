import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/admin/data/models/admin_review_model.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_reviews_provider.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_empty_state.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/shared/widgets/custom_alert_dialog.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminReviewsProvider>().load();
    });
  }

  void _confirmDelete(BuildContext ctx, AdminReviewModel review) {
    CustomAlertDialog.show(
      context: ctx,
      title: 'Delete review?',
      description:
          'Review by "${review.userName}" on "${review.productName}" will be permanently removed.',
      actionLabel: 'Delete',
      actionVariant: ButtonVariant.destructive,
      onAction: () async {
        final ok =
            await context.read<AdminReviewsProvider>().delete(review.id);
        if (!ctx.mounted) return;
        if (ok) {
          ToastHelper.showSuccess(ctx, 'Review deleted');
        } else {
          ToastHelper.showError(
            ctx,
            context.read<AdminReviewsProvider>().error ?? 'Delete failed',
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
              Text(
                'Reviews',
                style: const TextStyle(
                  fontFamily: AppAssets.instrumentSerif,
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
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
    return Consumer<AdminReviewsProvider>(
      builder: (context, p, _) {
        if (p.isLoading) return _skeleton();
        if (p.error != null && p.reviews.isEmpty) {
          return AdminErrorState(message: p.error!, onRetry: p.reload);
        }
        if (p.reviews.isEmpty) {
          return const AdminEmptyState(
            icon: Icons.star_outline,
            message: 'No reviews yet.',
          );
        }
        return RefreshIndicator(
          color: Colors.black,
          onRefresh: p.reload,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: p.reviews.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (ctx, i) => _ReviewTile(
              review: p.reviews[i],
              onDelete: () => _confirmDelete(ctx, p.reviews[i]),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Skeleton(width: 120, height: 13),
                  const Spacer(),
                  Skeleton(width: 60, height: 11),
                ],
              ),
              const SizedBox(height: 6),
              Skeleton(width: 160, height: 11),
              const SizedBox(height: 6),
              Skeleton(height: 11),
            ],
          ),
        ),
      );
}

class _ReviewTile extends StatelessWidget {
  final AdminReviewModel review;
  final VoidCallback onDelete;

  const _ReviewTile({required this.review, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StarRating(rating: review.rating),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 18, color: Colors.black54),
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child:
                        Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'by ${review.userName} · ${_formatDate(review.createdAt)}',
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 11,
              color: Colors.black38,
            ),
          ),
          if (review.title != null) ...[
            const SizedBox(height: 6),
            Text(
              review.title!,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (review.body != null) ...[
            const SizedBox(height: 4),
            Text(
              review.body!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

class _StarRating extends StatelessWidget {
  final int rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: i < rating ? const Color(0xFFF57F17) : Colors.black26,
        ),
      ),
    );
  }
}
