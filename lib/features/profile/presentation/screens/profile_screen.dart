import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // Extract first name only from the full name stored in the DB
    final fullName = authProvider.currentUser?.fullName ?? '';
    final firstName = fullName.split(' ').first;

    final List<String> menuItems = [
      'Overview',
      'Orders',
      'Rewards',
      'Personal Information',
      'Addresses',
      'Payment',
      'Saved Items',
      'Sign Out',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Text(
              'Hi, $firstName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: menuItems.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                height: 1,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSignOut = item == 'Sign Out';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  title: Text(
                    item,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: isSignOut ? Colors.red : Colors.black,
                    ),
                  ),
                  onTap: isSignOut
                      ? () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Sign out'),
                              content: const Text(
                                'Are you sure you want to sign out?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Sign out',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            await context.read<AuthProvider>().signOut();
                            // Router redirect handles navigation to onboarding
                          }
                        }
                      : () {
                          switch (item) {
                            case 'Orders':
                              context.push(AppRouter.profileOrders);
                            case 'Personal Information':
                              context.push(AppRouter.profilePersonalInfo);
                            case 'Addresses':
                              context.push(AppRouter.profileAddresses);
                            case 'Payment':
                              context.push(AppRouter.profilePayment);
                            case 'Saved Items':
                              context.push(AppRouter.profileSavedItems);
                            case 'Rewards':
                              context.push(AppRouter.profileRewards);
                          }
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
