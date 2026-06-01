import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

/// Compact search input used at the top of admin list screens.
class AdminSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const AdminSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<AdminSearchBar> createState() => _AdminSearchBarState();
}

class _AdminSearchBarState extends State<AdminSearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        style: const TextStyle(
          fontFamily: AppAssets.manrope,
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 14,
            color: Colors.black38,
          ),
          prefixIcon: const Icon(Icons.search, size: 18, color: Colors.black38),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.black38),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
        onTap: () => setState(() {}),
      ),
    );
  }
}
