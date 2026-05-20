// All routes/navigation setup
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:watch_hub/features/auth/presentation/screens/login_screen.dart';
import 'package:watch_hub/features/auth/presentation/screens/signup_screen.dart';
import 'package:watch_hub/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:watch_hub/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:watch_hub/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:watch_hub/features/home/presentation/screens/home_screen.dart';
import 'package:watch_hub/features/auth/presentation/screens/splash_screen.dart';
import 'package:watch_hub/shared/widgets/secure_screen.dart';
import 'package:watch_hub/features/brands/presentation/screens/brands_screen.dart';
import 'package:watch_hub/features/brands/presentation/screens/brand_detail_screen.dart';
import 'package:watch_hub/features/profile/presentation/screens/profile_screen.dart';
import 'package:watch_hub/features/profile/presentation/screens/orders_screen.dart';
import 'package:watch_hub/features/profile/presentation/screens/rewards_screen.dart';
import 'package:watch_hub/features/profile/presentation/screens/personal_info_screen.dart';
import 'package:watch_hub/features/profile/presentation/screens/addresses_screen.dart';
import 'package:watch_hub/features/profile/presentation/screens/payment_screen.dart';
import 'package:watch_hub/features/profile/presentation/screens/saved_items_screen.dart';
import 'package:watch_hub/features/cart/presentation/screens/cart_screen.dart';
import 'package:watch_hub/features/product/presentation/screens/product_page.dart';
import 'package:watch_hub/features/admin/presentation/screens/admin_shell_screen.dart';
import 'package:watch_hub/features/profile/presentation/screens/checkout_screen.dart';
import 'package:watch_hub/features/profile/presentation/screens/order_detail_screen.dart';
import 'package:watch_hub/features/support/presentation/screens/faq_screen.dart';
import 'package:watch_hub/features/support/presentation/screens/contact_screen.dart';

/// App Router Configuration
class AppRouter {
  AppRouter._();

  // ==================== ROUTE NAMES ====================
  static const String onboarding = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String splash = '/splash';
  static const String newArrivals = '/new';
  static const String bestsellers = '/bestsellers';
  static const String brands = '/brands';
  static const String brandDetail = '/brands/:id';
  static const String profile = '/profile';
  static const String profileOrders = '/profile/orders';
  static const String profileOrderDetail = '/profile/orders/:id';
  static const String checkout = '/checkout';
  static const String faq = '/faq';
  static const String contact = '/contact';
  static const String profileRewards = '/profile/rewards';
  static const String profilePersonalInfo = '/profile/personal-info';
  static const String profileAddresses = '/profile/addresses';
  static const String profilePayment = '/profile/payment';
  static const String profileSavedItems = '/profile/saved-items';
  static const String cart = '/cart';
  static const String productDetail = '/products/:id';
  static const String admin = '/admin';

  // ==================== ROUTER FACTORY ====================
  /// Creates a GoRouter bound to [authProvider] so redirect re-evaluates
  /// whenever the auth state changes (ChangeNotifier → refreshListenable).
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: true,
      refreshListenable: authProvider,

      // ── Auth redirect ────────────────────────────────────────
      redirect: (context, state) {
        final loc = state.matchedLocation;

        // Hold all navigation on the splash screen until the server-side
        // session check completes (prevents stale cached tokens getting through).
        if (!authProvider.isInitialized) {
          return loc == splash ? null : splash;
        }

        final isLoggedIn = authProvider.isLoggedIn;
        final isAdmin = authProvider.isAdmin;

        // Once initialized, navigate away from the splash screen.
        if (loc == splash) {
          if (!isLoggedIn) return onboarding;
          return isAdmin ? admin : home;
        }

        // Protected customer routes require login, admin gets bounced to /admin.
        final isCustomerZone = loc.startsWith(home);
        // Admin zone requires login + admin role.
        final isAdminZone = loc.startsWith(admin);
        // Guest-only routes redirect signed-in users away.
        final isGuestOnly = loc == onboarding || loc == login || loc == signup;

        if (!isLoggedIn && (isCustomerZone || isAdminZone)) return login;
        if (isLoggedIn && isGuestOnly) return isAdmin ? admin : home;
        // Admin trying to access customer zone → bounce to admin panel.
        if (isLoggedIn && isAdmin && isCustomerZone) return admin;
        // Customer trying to access admin zone → bounce to home.
        if (isLoggedIn && !isAdmin && isAdminZone) return home;
        return null;
      },

      routes: [
        // Splash — full-screen loader while auth session is validated
        GoRoute(
          path: splash,
          pageBuilder: (context, state) =>
              _slide(context, state, const SplashScreen()),
        ),

        // Onboarding
        GoRoute(
          path: onboarding,
          pageBuilder: (context, state) =>
              _slide(context, state, const OnboardingScreen()),
        ),

        // Login
        GoRoute(
          path: login,
          pageBuilder: (context, state) =>
              _slide(context, state, const SecureScreen(child: LoginScreen())),
        ),

        // Signup
        GoRoute(
          path: signup,
          pageBuilder: (context, state) =>
              _slide(context, state, const SecureScreen(child: SignupScreen())),
        ),

        // Forgot Password
        GoRoute(
          path: forgotPassword,
          pageBuilder: (context, state) => _slide(
            context,
            state,
            const SecureScreen(child: ForgotPasswordScreen()),
          ),
        ),

        // OTP Verification — extra: {'email': String, 'type': 'signup'|'recovery'}
        GoRoute(
          path: otpVerification,
          pageBuilder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};
            final email = args['email'] as String? ?? '';
            final type = args['type'] as String? ?? 'signup';
            return _slide(
              context,
              state,
              SecureScreen(
                child: OtpVerificationScreen(email: email, otpType: type),
              ),
            );
          },
        ),

        // Reset Password — extra: String email
        GoRoute(
          path: resetPassword,
          pageBuilder: (context, state) {
            final email = state.extra as String? ?? '';
            return _slide(
              context,
              state,
              SecureScreen(child: ResetPasswordScreen(email: email)),
            );
          },
        ),

        // Home
        GoRoute(
          path: home,
          pageBuilder: (context, state) =>
              _slide(context, state, const HomeScreen()),
        ),

        // Brands
        GoRoute(
          path: brands,
          pageBuilder: (context, state) =>
              _slide(context, state, const BrandsScreen()),
        ),

        // Brand Detail — /brands/:id
        GoRoute(
          path: brandDetail,
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _slide(context, state, BrandDetailScreen(brandId: id));
          },
        ),

        // Profile
        GoRoute(
          path: profile,
          pageBuilder: (context, state) =>
              _slide(context, state, const ProfileScreen()),
        ),

        // Profile — Orders
        GoRoute(
          path: profileOrders,
          pageBuilder: (context, state) =>
              _slide(context, state, const OrdersScreen()),
        ),

        // Profile — Order Detail
        GoRoute(
          path: profileOrderDetail,
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _slide(context, state, OrderDetailScreen(orderId: id));
          },
        ),

        // Checkout
        GoRoute(
          path: checkout,
          pageBuilder: (context, state) =>
              _slide(context, state, const CheckoutScreen()),
        ),

        // FAQ
        GoRoute(
          path: faq,
          pageBuilder: (context, state) =>
              _slide(context, state, const FaqScreen()),
        ),

        // Contact
        GoRoute(
          path: contact,
          pageBuilder: (context, state) =>
              _slide(context, state, const ContactScreen()),
        ),

        // Profile — Rewards
        GoRoute(
          path: profileRewards,
          pageBuilder: (context, state) =>
              _slide(context, state, const RewardsScreen()),
        ),

        // Profile — Personal Information
        GoRoute(
          path: profilePersonalInfo,
          pageBuilder: (context, state) =>
              _slide(context, state, const PersonalInfoScreen()),
        ),

        // Profile — Addresses
        GoRoute(
          path: profileAddresses,
          pageBuilder: (context, state) =>
              _slide(context, state, const AddressesScreen()),
        ),

        // Profile — Payment
        GoRoute(
          path: profilePayment,
          pageBuilder: (context, state) =>
              _slide(context, state, const PaymentScreen()),
        ),

        // Profile — Saved Items
        GoRoute(
          path: profileSavedItems,
          pageBuilder: (context, state) =>
              _slide(context, state, const SavedItemsScreen()),
        ),

        // Cart
        GoRoute(
          path: cart,
          pageBuilder: (context, state) =>
              _slide(context, state, const CartScreen()),
        ),

        // Product Detail
        GoRoute(
          path: productDetail,
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _slide(context, state, ProductPage(productId: id));
          },
        ),

        // Admin panel — accessible only to users with role == 'admin'
        GoRoute(
          path: admin,
          pageBuilder: (context, state) =>
              _slide(context, state, const AdminShellScreen()),
        ),
      ],
    );
  }

  // ==================== CUSTOM SLIDE TRANSITION ====================
  static CustomTransitionPage<void> _slide(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
