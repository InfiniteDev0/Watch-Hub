import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/admin/data/models/admin_message_model.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_messages_provider.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_empty_state.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/shared/widgets/custom_alert_dialog.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminMessagesProvider>().load();
    });
  }

  void _openDetail(AdminMessageModel msg) {
    final prov = context.read<AdminMessagesProvider>();
    if (!msg.isRead) {
      prov.markRead(msg.id, true);
    }
    showDialog(
      context: context,
      builder: (_) => _MessageDetailDialog(
        message: msg.copyWith(isRead: true),
        onDelete: () {
          Navigator.of(context).pop();
          _confirmDelete(context, msg);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AdminMessageModel msg) {
    CustomAlertDialog.show(
      context: ctx,
      title: 'Delete message?',
      description: 'Message from "${msg.fullName}" will be permanently removed.',
      actionLabel: 'Delete',
      actionVariant: ButtonVariant.destructive,
      onAction: () async {
        final ok = await context.read<AdminMessagesProvider>().delete(msg.id);
        if (!ctx.mounted) return;
        if (ok) {
          ToastHelper.showSuccess(ctx, 'Message deleted');
        } else {
          ToastHelper.showError(
            ctx,
            context.read<AdminMessagesProvider>().error ?? 'Delete failed',
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
                  const Expanded(
                    child: Text(
                      'Feedback',
                      style: TextStyle(
                        fontFamily: AppAssets.instrumentSerif,
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Consumer<AdminMessagesProvider>(
                    builder: (_, p, __) {
                      if (p.unreadCount == 0) return const SizedBox();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${p.unreadCount} new',
                          style: const TextStyle(
                            fontFamily: AppAssets.manrope,
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<AdminMessagesProvider>(
                builder: (_, p, __) {
                  return Row(
                    children: [
                      _FilterPill(
                        label: 'All',
                        active: !p.showUnreadOnly,
                        onTap: () => p.toggleUnreadFilter(false),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Unread',
                        active: p.showUnreadOnly,
                        onTap: () => p.toggleUnreadFilter(true),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<AdminMessagesProvider>(
      builder: (context, p, _) {
        if (p.isLoading) return _skeleton();
        if (p.error != null && p.messages.isEmpty) {
          return AdminErrorState(message: p.error!, onRetry: p.reload);
        }
        if (p.messages.isEmpty) {
          return AdminEmptyState(
            icon: Icons.inbox_outlined,
            message: p.showUnreadOnly
                ? 'No unread messages.'
                : 'No feedback yet.\nUser submissions will appear here.',
          );
        }
        return RefreshIndicator(
          color: Colors.black,
          onRefresh: p.reload,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: p.messages.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (ctx, i) => _MessageTile(
              message: p.messages[i],
              onTap: () => _openDetail(p.messages[i]),
              onDelete: () => _confirmDelete(ctx, p.messages[i]),
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
                children: const [
                  Skeleton(width: 120, height: 13),
                  Spacer(),
                  Skeleton(width: 60, height: 11),
                ],
              ),
              const SizedBox(height: 6),
              const Skeleton(width: 180, height: 11),
              const SizedBox(height: 6),
              const Skeleton(height: 11),
            ],
          ),
        ),
      );
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.black : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final AdminMessageModel message;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MessageTile({
    required this.message,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isRead)
              Container(
                margin: const EdgeInsets.only(top: 5, right: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppAssets.manrope,
                            fontSize: 14,
                            fontWeight: message.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(message.createdAt),
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 11,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.subject,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 12,
                      color: Colors.black45,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: Colors.black54),
              onSelected: (v) {
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
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

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day} ${_months[d.month - 1]}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

class _MessageDetailDialog extends StatelessWidget {
  final AdminMessageModel message;
  final VoidCallback onDelete;

  const _MessageDetailDialog({
    required this.message,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.subject,
                style: const TextStyle(
                  fontFamily: AppAssets.instrumentSerif,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: Colors.black45),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message.fullName,
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.email_outlined,
                      size: 16, color: Colors.black45),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SelectableText(
                      message.email,
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule,
                      size: 16, color: Colors.black45),
                  const SizedBox(width: 6),
                  Text(
                    _formatFullDate(message.createdAt),
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  message.message,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Delete',
                    variant: ButtonVariant.destructive,
                    size: ButtonSize.sm,
                    onPressed: onDelete,
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    text: 'Close',
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.sm,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFullDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year} at $hh:$mm';
  }
}
