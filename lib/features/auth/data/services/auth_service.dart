import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps all Supabase Auth calls for the Flutter app.
/// All auth (signup, login, OTP, password reset) goes through
/// Supabase SDK directly — the Node.js backend verifies the JWT
/// for every protected API call via its auth middleware.
class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  // ── Current session state ─────────────────────────────────────
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isSignedIn => currentSession != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Sign Up ────────────────────────────────────────────────────
  /// Creates a new account. Supabase sends a 6-digit OTP to the email.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  // ── Sign In ────────────────────────────────────────────────────
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Global signout failed (e.g. network error). Force-clear the local
      // session so the user is never left in a phantom signed-in state
      // after restarting the app.
      await _client.auth.signOut(scope: SignOutScope.local);
    }
  }

  // ── Verify OTP ─────────────────────────────────────────────────
  /// type: OtpType.signup  → confirms new account
  /// type: OtpType.recovery → confirms password-reset request
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    return _client.auth.verifyOTP(email: email, token: token, type: type);
  }

  // ── Resend OTP ─────────────────────────────────────────────────
  Future<ResendResponse> resendOtp({
    required String email,
    required OtpType type,
  }) async {
    return _client.auth.resend(type: type, email: email);
  }

  // ── Password Reset (sends OTP email) ──────────────────────────
  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ── Update Password (after recovery OTP verified = session active)
  Future<UserResponse> updatePassword(String newPassword) async {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ── Refresh Session ────────────────────────────────────────────
  Future<AuthResponse> refreshSession() async {
    return _client.auth.refreshSession();
  }
}
