import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_hub/features/auth/data/models/auth_user_model.dart';
import 'package:watch_hub/features/auth/data/services/auth_service.dart';

/// Translates AuthService calls into domain results and normalises errors.
class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  // ── Passthrough getters ───────────────────────────────────────
  User? get currentUser => _service.currentUser;
  bool get isSignedIn => _service.isSignedIn;
  Stream<AuthState> get authStateChanges => _service.authStateChanges;

  // ── Sign Up ────────────────────────────────────────────────────
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _service.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
    if (response.user == null) {
      throw Exception('Signup failed. Please try again.');
    }
    // Sign out any auto-created session so the user must log in explicitly
    if (response.session != null) {
      await _service.signOut();
    }
  }

  // ── Sign In ────────────────────────────────────────────────────
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _service.signIn(email: email, password: password);
    if (response.user == null) {
      throw Exception('Invalid email or password.');
    }
    return AuthUserModel.fromSupabaseUser(response.user!);
  }

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() => _service.signOut();

  // ── Verify OTP ─────────────────────────────────────────────────
  /// Returns the signed-in user after successful OTP verification.
  Future<AuthUserModel?> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    final response = await _service.verifyOtp(
      email: email,
      token: token,
      type: type,
    );
    if (response.user != null) {
      return AuthUserModel.fromSupabaseUser(response.user!);
    }
    return null;
  }

  // ── Resend OTP ─────────────────────────────────────────────────
  Future<void> resendOtp({required String email, required OtpType type}) async {
    await _service.resendOtp(email: email, type: type);
  }

  // ── Password Reset ─────────────────────────────────────────────
  Future<void> resetPasswordForEmail(String email) =>
      _service.resetPasswordForEmail(email);

  // ── Update Password ────────────────────────────────────────────
  Future<void> updatePassword(String newPassword) async {
    final response = await _service.updatePassword(newPassword);
    if (response.user == null) {
      throw Exception('Failed to update password.');
    }
  }

  // ── Refresh Session ───────────────────────────────────────────
  /// Forces a server-side token rotation and validation.
  /// Throws [AuthException] if the user was deleted or session was revoked.
  Future<void> refreshSession() async {
    final response = await _service.refreshSession();
    if (response.session == null) {
      throw const AuthException('Session could not be refreshed.');
    }
  }
}
