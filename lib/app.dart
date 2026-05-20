import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/providers/connectivity_provider.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/core/theme/app_theme.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/shared/screens/no_internet_screen.dart';

class WatchHubApp extends StatefulWidget {
  final AuthProvider authProvider;

  const WatchHubApp({super.key, required this.authProvider});

  @override
  State<WatchHubApp> createState() => _WatchHubAppState();
}

class _WatchHubAppState extends State<WatchHubApp> {
  late final _router = AppRouter.createRouter(widget.authProvider);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WatchHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
      // Overlay the no-internet screen on top of all routes when offline
      builder: (context, child) {
        return Consumer<ConnectivityProvider>(
          builder: (context, connectivity, _) {
            if (!connectivity.isOnline) {
              return const NoInternetScreen();
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
