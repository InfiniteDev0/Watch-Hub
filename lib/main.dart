import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_hub/app.dart';
import 'package:watch_hub/core/providers/connectivity_provider.dart';
import 'package:watch_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:watch_hub/features/auth/data/services/auth_service.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/features/cart/logic/providers/cart_provider.dart';
import 'package:watch_hub/features/orders/logic/providers/order_provider.dart';
import 'package:watch_hub/features/profile/logic/providers/profile_provider.dart';
import 'package:watch_hub/features/reviews/logic/providers/review_provider.dart';
import 'package:watch_hub/features/wishlist/logic/providers/wishlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode permanently
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  // Pass --dart-define=ENV=production for prod builds, defaults to local
  const env = String.fromEnvironment('ENV', defaultValue: 'local');
  await dotenv.load(fileName: '.env.$env');

  // Initialise Supabase (handles session persistence automatically)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Build the dependency graph
  final authProvider = AuthProvider(AuthRepository(AuthService()));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: WatchHubApp(authProvider: authProvider),
    ),
  );
}
