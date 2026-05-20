import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_hub/features/auth/data/models/auth_user_model.dart';
import 'package:watch_hub/features/auth/data/repositories/auth_repository.dart';

// ignore: constant_identifier_names
const _kAdminRole = 'admin';

/// Central auth state for the app.
/// Screens read from this provider via Provider.of / Consumer.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  AuthProvider(this._repo) {
    _init();
  }

  // ── State ──────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isInitialized =
      false; // false until the cold-start session check completes
  AuthUserModel? _currentUser;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;
  AuthUserModel? get currentUser => _currentUser;
  String? get error => _error;

  /// True when the signed-in user has the admin role.
  bool get isAdmin => _currentUser?.role == _kAdminRole;

  // ── Role fetch ─────────────────────────────────────────────────
  /// Fetches the authoritative role from the `profiles` table and patches
  /// [_currentUser]. JWT metadata can lag behind — the DB is the truth.
  Future<void> _fetchAndApplyRole(User user) async {
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      final dbRole = res['role'] as String? ?? 'customer';
      if (_currentUser != null && _currentUser!.role != dbRole) {
        _currentUser = AuthUserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          fullName: _currentUser!.fullName,
          phone: _currentUser!.phone,
          avatarUrl: _currentUser!.avatarUrl,
          role: dbRole,
          createdAt: _currentUser!.createdAt,
        );
        notifyListeners();
      }
    } catch (_) {
      // Silently fall back to JWT metadata role already on _currentUser
    }
  }

  // ── Init ───────────────────────────────────────────────────────
  void _init() {
    // Never trust the local cache directly — validate against the server
    // on every cold start via the initialSession event.
    _repo.authStateChanges.listen((AuthState state) async {
      await _onAuthStateChange(state);
    });
  }

  Future<void> _onAuthStateChange(AuthState state) async {
    switch (state.event) {
      // ── Cold start: validate the cached session with the server ───────
      case AuthChangeEvent.initialSession:
        if (state.session != null) {
          try {
            // Forces a refresh-token round-trip to the server.
            await _repo.refreshSession();
            final user = _repo.currentUser;
            if (user != null) {
              _isLoggedIn = true;
              _currentUser = AuthUserModel.fromSupabaseUser(user);
              await _fetchAndApplyRole(user);
            }
          } on AuthException catch (_) {
            _isLoggedIn = false;
            _currentUser = null;
            try {
              await _repo.signOut();
            } catch (_) {}
          } catch (_) {
            _isLoggedIn = true;
            _currentUser = AuthUserModel.fromSupabaseUser(state.session!.user);
          }
        } else {
          _isLoggedIn = false;
          _currentUser = null;
        }
        _isInitialized = true;
        break;

      // ── Active-session events ─────────────────────────────────────────
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
        final user = state.session?.user;
        if (user != null) {
          _isLoggedIn = true;
          _currentUser = AuthUserModel.fromSupabaseUser(user);
          await _fetchAndApplyRole(user);
        }
        if (!_isInitialized) _isInitialized = true;
        break;

      case AuthChangeEvent.signedOut:
        _isLoggedIn = false;
        _currentUser = null;
        if (!_isInitialized) _isInitialized = true;
        break;

      default:
        break;
    }
    notifyListeners();
  }

  // ── Sign Up ────────────────────────────────────────────────────
  /// Returns true on success. Supabase sends a 6-digit confirmation OTP.
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    try {
      await _repo.signUp(email: email, password: password, fullName: fullName);
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign In ────────────────────────────────────────────────────
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      final user = await _repo.signIn(email: email, password: password);
      _isLoggedIn = true;
      _currentUser = user;
      // Fetch the authoritative role from the DB RIGHT NOW, before
      // _setLoading(false) fires notifyListeners and the router redirects.
      // JWT metadata doesn't carry the role, so without this the router
      // always sees isAdmin=false and briefly sends admins to /home.
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) await _fetchAndApplyRole(supabaseUser);
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Verify OTP ─────────────────────────────────────────────────
  Future<bool> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    _setLoading(true);
    try {
      final user = await _repo.verifyOtp(
        email: email,
        token: token,
        type: type,
      );
      if (type == OtpType.signup && user != null) {
        _isLoggedIn = true;
        _currentUser = user;
        final supabaseUser = Supabase.instance.client.auth.currentUser;
        if (supabaseUser != null) await _fetchAndApplyRole(supabaseUser);
      }
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Resend OTP ─────────────────────────────────────────────────
  Future<bool> resendOtp({required String email, required OtpType type}) async {
    _setLoading(true);
    try {
      await _repo.resendOtp(email: email, type: type);
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Send Password Reset OTP ────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _repo.resetPasswordForEmail(email);
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Update Password ────────────────────────────────────────────
  /// Call AFTER recovery OTP is verified (session is active).
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    try {
      await _repo.updatePassword(newPassword);
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _repo.signOut();
      _isLoggedIn = false;
      _currentUser = null;
      _clearError();
    } finally {
      _setLoading(false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
