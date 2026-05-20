import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Blocks screenshots and screen recordings while this screen is visible.
///
/// Works on Android via a native MethodChannel that sets/clears
/// WindowManager.LayoutParams.FLAG_SECURE.
/// iOS does not allow apps to block screenshots — this is an OS limitation.
class SecureScreen extends StatefulWidget {
  final Widget child;
  const SecureScreen({super.key, required this.child});

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  static const _channel = MethodChannel('com.example.frontend/window_security');

  @override
  void initState() {
    super.initState();
    _setSecure(true);
  }

  @override
  void dispose() {
    _setSecure(false);
    super.dispose();
  }

  Future<void> _setSecure(bool secure) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('setSecure', {'secure': secure});
    } on MissingPluginException {
      // Channel not registered (e.g. tests / desktop) — ignore
    } catch (_) {
      // Non-critical, fail silently
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
