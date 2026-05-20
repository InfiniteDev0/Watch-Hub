import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_hub/core/network/api_constants.dart';

/// Singleton Dio client that automatically injects the Supabase JWT
/// into every request and attempts a token refresh on 401 responses.
class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static Dio get dio {
    _dio ??= _build();
    return _dio!;
  }

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // ── Attach Bearer token ─────────────────────────────────
        onRequest: (options, handler) {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] =
                'Bearer ${session.accessToken}';
          }
          handler.next(options);
        },

        // ── Auto-refresh on 401 ─────────────────────────────────
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              await Supabase.instance.client.auth.refreshSession();
              final session =
                  Supabase.instance.client.auth.currentSession;
              if (session != null) {
                final opts = error.requestOptions;
                opts.headers['Authorization'] =
                    'Bearer ${session.accessToken}';
                final retried = await dio.fetch(opts);
                handler.resolve(retried);
                return;
              }
            } catch (_) {
              // Refresh failed — let caller handle sign-out
            }
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Call after sign-out to clear the cached instance so the next
  /// request builds a fresh client without stale headers.
  static void reset() => _dio = null;
}
