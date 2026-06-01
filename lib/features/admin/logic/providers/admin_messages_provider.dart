import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/admin/data/models/admin_message_model.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';

class AdminMessagesProvider extends ChangeNotifier {
  final AdminRepository _repo;
  AdminMessagesProvider(this._repo);

  List<AdminMessageModel> _all = [];
  bool _showUnreadOnly = false;
  bool isLoading = false;
  String? error;

  bool get showUnreadOnly => _showUnreadOnly;

  List<AdminMessageModel> get messages =>
      _showUnreadOnly ? _all.where((m) => !m.isRead).toList() : _all;

  int get unreadCount => _all.where((m) => !m.isRead).length;

  void toggleUnreadFilter(bool v) {
    _showUnreadOnly = v;
    notifyListeners();
  }

  Future<void> load() async {
    if (_all.isNotEmpty) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _all = await _repo.getMessages(limit: 200);
    } catch (e) {
      error = _msg(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    _all = [];
    await load();
  }

  Future<bool> markRead(String id, bool isRead) async {
    try {
      final updated = await _repo.markMessageRead(id, isRead);
      _all = _all.map((m) => m.id == id ? updated : m).toList();
      notifyListeners();
      return true;
    } catch (e) {
      error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repo.deleteMessage(id);
      _all = _all.where((m) => m.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  String _msg(Object e) {
    final s = e.toString();
    return s.startsWith('Exception:') ? s.substring(10).trim() : s;
  }
}
