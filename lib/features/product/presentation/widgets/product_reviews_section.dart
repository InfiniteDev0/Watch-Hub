import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/features/reviews/data/models/review_model.dart';
import 'package:watch_hub/features/reviews/logic/providers/review_provider.dart';

class ProductReviewsSection extends StatefulWidget {
  final String productId;

  const ProductReviewsSection({super.key, required this.productId});

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  bool _expanded = true;

  void _showWriteReviewSheet(BuildContext context) {
    final rp = context.read<ReviewProvider>();
    final existing = rp.myReview;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: rp,
        child: _WriteReviewSheet(
          productId: widget.productId,
          existingReview: existing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, rp, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Collapsible header ─────────────────────────────────────
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Reviews',
                          style: TextStyle(
                            fontFamily: AppAssets.instrumentSerif,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        if (rp.summary.total > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${rp.summary.total})',
                            style: const TextStyle(
                              fontFamily: AppAssets.manrope,
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
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

            if (_expanded) ...[
              // ── Loading ──────────────────────────────────────────────
              if (rp.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
              else ...[
                // ── Summary bar ────────────────────────────────────────
                if (rp.summary.total > 0) ...[
                  _ReviewSummaryBar(summary: rp.summary),
                  const SizedBox(height: 20),
                ],

                // ── Sort + Write Review row ────────────────────────────
                Row(
                  children: [
                    _ReviewSortChip(
                      label: 'Newest',
                      active: rp.sort == ReviewSort.newest,
                      onTap: () => rp.setSort(ReviewSort.newest),
                    ),
                    const SizedBox(width: 8),
                    _ReviewSortChip(
                      label: '★ High',
                      active: rp.sort == ReviewSort.highestRating,
                      onTap: () => rp.setSort(ReviewSort.highestRating),
                    ),
                    const SizedBox(width: 8),
                    _ReviewSortChip(
                      label: '★ Low',
                      active: rp.sort == ReviewSort.lowestRating,
                      onTap: () => rp.setSort(ReviewSort.lowestRating),
                    ),
                    const Spacer(),
                    if (context.read<AuthProvider>().isLoggedIn)
                      GestureDetector(
                        onTap: () => _showWriteReviewSheet(context),
                        child: Text(
                          rp.myReview != null
                              ? 'Edit Review'
                              : 'Write a Review',
                          style: const TextStyle(
                            fontFamily: AppAssets.manrope,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Review cards ───────────────────────────────────────
                if (rp.reviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No reviews yet. Be the first!',
                        style: TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  )
                else
                  ...rp.reviews.map(
                    (r) => _ReviewCard(
                      review: r,
                      isMine: rp.myReview?.id == r.id,
                      onDelete: () async {
                        final ok = await rp.deleteReview(r.id);
                        if (!ok && context.mounted) {
                          ToastHelper.showError(
                            context,
                            rp.submitError ?? 'Could not delete review',
                          );
                        }
                      },
                      onEdit: () => _showWriteReviewSheet(context),
                    ),
                  ),
              ],
            ],

            const Divider(height: 1, color: Color(0xFFE5E5E5)),
          ],
        );
      },
    );
  }
}

// ─── Review Summary Bar ────────────────────────────────────────────────────

class _ReviewSummaryBar extends StatelessWidget {
  final ReviewSummary summary;

  const _ReviewSummaryBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              summary.formattedAverage,
              style: const TextStyle(
                fontFamily: AppAssets.instrumentSerif,
                fontSize: 44,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            _StarRow(rating: summary.average, size: 14),
            const SizedBox(height: 4),
            Text(
              '${summary.total} ${summary.total == 1 ? 'review' : 'reviews'}',
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [5, 4, 3, 2, 1].map((star) {
              final pct = summary.percentFor(star);
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star,
                      size: 10,
                      color: Color(0xFFF5A623),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFEEEEEE),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${summary.distribution[star] ?? 0}',
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Sort Chip ─────────────────────────────────────────────────────────────

class _ReviewSortChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ReviewSortChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.transparent,
          border: Border.all(
            color: active ? Colors.black : const Color(0xFFD0D0D0),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

// ─── Review Card ───────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isMine;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ReviewCard({
    required this.review,
    required this.isMine,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: Text(
                  review.initials,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      review.formattedDate,
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              _StarRow(rating: review.rating.toDouble(), size: 13),
              if (isMine) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (review.title != null && review.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                review.title!,
                style: const TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          if (review.body != null && review.body!.isNotEmpty)
            Text(
              review.body!,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
        ],
      ),
    );
  }
}

// ─── Star Row (display-only) ───────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && (rating - i) >= 0.5;
        return Icon(
          filled
              ? Icons.star
              : half
                  ? Icons.star_half
                  : Icons.star_border,
          size: size,
          color: const Color(0xFFF5A623),
        );
      }),
    );
  }
}

// ─── Write Review Sheet ────────────────────────────────────────────────────

class _WriteReviewSheet extends StatefulWidget {
  final String productId;
  final ReviewModel? existingReview;

  const _WriteReviewSheet({
    required this.productId,
    this.existingReview,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  late int _selectedRating;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existingReview;
    _selectedRating = e?.rating ?? 0;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _bodyCtrl = TextEditingController(text: e?.body ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating'),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    final rp = context.read<ReviewProvider>();
    final ok = await rp.submitReview(
      widget.productId,
      rating: _selectedRating,
      title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ToastHelper.showSuccess(context, 'Review submitted — thank you!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rp.submitError ?? 'Could not submit review'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<ReviewProvider>().submitting;
    final isEdit = widget.existingReview != null;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEdit ? 'Edit Your Review' : 'Write a Review',
            style: const TextStyle(
              fontFamily: AppAssets.instrumentSerif,
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'YOUR RATING',
            style: TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    starIndex <= _selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    size: 36,
                    color: starIndex <= _selectedRating
                        ? const Color(0xFFF5A623)
                        : Colors.black26,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 15,
            ),
            decoration: const InputDecoration(
              labelText: 'Title (optional)',
              labelStyle: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                color: Colors.black54,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD0D0D0)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyCtrl,
            minLines: 3,
            maxLines: 5,
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 15,
            ),
            decoration: const InputDecoration(
              labelText: 'Your review (optional)',
              labelStyle: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                color: Colors.black54,
              ),
              alignLabelWithHint: true,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD0D0D0)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isEdit ? 'Update Review' : 'Submit Review',
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
