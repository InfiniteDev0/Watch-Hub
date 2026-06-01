import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/admin/data/models/admin_user_model.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_users_provider.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_empty_state.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_search_bar.dart';
import 'package:watch_hub/features/admin/presentation/widgets/admin_status_badge.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/shared/widgets/custom_alert_dialog.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().load();
    });
  }

  void _confirmDelete(BuildContext ctx, AdminUserModel user) {
    CustomAlertDialog.show(
      context: ctx,
      title: 'Delete user?',
      description:
          '"${user.fullName ?? user.id}" will be permanently removed.',
      actionLabel: 'Delete',
      actionVariant: ButtonVariant.destructive,
      onAction: () async {
        final ok = await context.read<AdminUsersProvider>().delete(user.id);
        if (!ctx.mounted) return;
        if (ok) {
          ToastHelper.showSuccess(ctx, 'User deleted');
        } else {
          ToastHelper.showError(
            ctx,
            context.read<AdminUsersProvider>().error ?? 'Delete failed',
          );
        }
      },
    );
  }

  void _changeRole(BuildContext ctx, AdminUserModel user, String role) async {
    final ok = await context.read<AdminUsersProvider>().changeRole(user.id, role);
    if (!ctx.mounted) return;
    if (ok) {
      ToastHelper.showSuccess(ctx, 'Role updated to $role');
    } else {
      ToastHelper.showError(
        ctx,
        context.read<AdminUsersProvider>().error ?? 'Update failed',
      );
    }
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
                'Users',
                style: const TextStyle(
                  fontFamily: AppAssets.instrumentSerif,
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              AdminSearchBar(
                hint: 'Search by name…',
                onChanged: (q) =>
                    context.read<AdminUsersProvider>().search(q),
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
    return Consumer<AdminUsersProvider>(
      builder: (context, p, _) {
        if (p.isLoading) return _skeleton();
        if (p.error != null && p.users.isEmpty) {
          return AdminErrorState(
            message: p.error!,
            onRetry: p.load,
          );
        }
        if (p.users.isEmpty) {
          return const AdminEmptyState(
            icon: Icons.people_outline,
            message: 'No users found.',
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: p.users.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
          itemBuilder: (ctx, i) => _UserTile(
            user: p.users[i],
            onDelete: () => _confirmDelete(ctx, p.users[i]),
            onChangeRole: (role) => _changeRole(ctx, p.users[i], role),
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
              const Skeleton(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 140, height: 13),
                    const SizedBox(height: 6),
                    Skeleton(width: 90, height: 11),
                  ],
                ),
              ),
              Skeleton(width: 60, height: 24, borderRadius: 6),
            ],
          ),
        ),
      );
}

class _UserTile extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onDelete;
  final ValueChanged<String> onChangeRole;

  const _UserTile({
    required this.user,
    required this.onDelete,
    required this.onChangeRole,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.fullName);
    final joined = _formatDate(user.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF0F0F0),
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Joined $joined',
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 11,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AdminStatusBadge.role(user.role),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Colors.black54),
            onSelected: (v) {
              if (v == 'delete') onDelete();
              if (v == 'make_admin') onChangeRole('admin');
              if (v == 'make_customer') onChangeRole('customer');
            },
            itemBuilder: (_) => [
              if (user.role != 'admin')
                const PopupMenuItem(
                  value: 'make_admin',
                  child: Text('Make Admin'),
                ),
              if (user.role != 'customer')
                const PopupMenuItem(
                  value: 'make_customer',
                  child: Text('Make Customer'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
