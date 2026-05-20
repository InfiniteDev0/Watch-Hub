import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/features/profile/data/models/address_model.dart';
import 'package:watch_hub/features/profile/logic/providers/profile_provider.dart';
import 'add_edit_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<ProfileProvider>().fetchAddresses(userId);
      }
    });
  }

  void _openAddEdit(BuildContext context, {AddressModel? address}) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<ProfileProvider>(),
          child: AddEditAddressScreen(address: address),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('${address.street}, ${address.city}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        final ok = await context
            .read<ProfileProvider>()
            .deleteAddress(userId, address.id);
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<ProfileProvider>().addressesError ?? 'Delete failed',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Addresses',
          style: TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEdit(context),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
        label: const Text(
          'Add Address',
          style: TextStyle(fontFamily: AppAssets.manrope),
        ),
        icon: const Icon(Icons.add, size: 20),
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _AddressCardSkeleton(),
    );
  }

  Widget _buildBody(BuildContext context, ProfileProvider provider) {
    if (provider.addressesLoading) {
      return _buildSkeleton();
    }

    if (provider.addressesError != null && provider.addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.addressesError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  final userId =
                      context.read<AuthProvider>().currentUser?.id;
                  if (userId != null) {
                    context.read<ProfileProvider>().fetchAddresses(userId);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.addresses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined, size: 48, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'No saved addresses',
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add an address to speed up checkout',
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: provider.addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final address = provider.addresses[i];
        return _AddressCard(
          address: address,
          onEdit: () => _openAddEdit(context, address: address),
          onDelete: () => _confirmDelete(context, address),
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: address.isDefault ? Colors.black : const Color(0xFFE8E8E8),
          width: address.isDefault ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.fullName,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            address.street,
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '${address.city}, ${address.postalCode}',
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            address.country,
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: onDelete,
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressCardSkeleton extends StatelessWidget {
  const _AddressCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 140, height: 14, borderRadius: 4),
          SizedBox(height: 12),
          Skeleton(width: double.infinity, height: 12, borderRadius: 4),
          SizedBox(height: 8),
          Skeleton(width: 180, height: 12, borderRadius: 4),
          SizedBox(height: 8),
          Skeleton(width: 100, height: 12, borderRadius: 4),
          SizedBox(height: 16),
          Row(
            children: [
              Skeleton(width: 32, height: 12, borderRadius: 4),
              SizedBox(width: 20),
              Skeleton(width: 40, height: 12, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}
