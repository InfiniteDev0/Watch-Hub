import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/auth/data/models/auth_user_model.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo;

  ProfileProvider([ProfileRepository? repo])
      : _repo = repo ?? ProfileRepository();

  // ── Profile state ─────────────────────────────────────────────────
  AuthUserModel? _profile;
  bool _profileLoading = false;
  bool _profileSaving = false;
  String? _profileError;

  AuthUserModel? get profile => _profile;
  bool get profileLoading => _profileLoading;
  bool get profileSaving => _profileSaving;
  String? get profileError => _profileError;

  // ── Address state ─────────────────────────────────────────────────
  List<AddressModel> _addresses = [];
  bool _addressesLoading = false;
  bool _addressesSaving = false;
  String? _addressesError;

  List<AddressModel> get addresses => _addresses;
  bool get addressesLoading => _addressesLoading;
  bool get addressesSaving => _addressesSaving;
  String? get addressesError => _addressesError;

  // ── Profile actions ───────────────────────────────────────────────

  Future<void> fetchProfile(String userId) async {
    if (_profile == null) {
      _profileLoading = true;
      notifyListeners();
    }
    try {
      _profile = await _repo.fetchProfile(userId);
      _profileError = null;
    } catch (e) {
      _profileError = _readable(e);
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(
    String userId, {
    required String fullName,
    required String phone,
  }) async {
    _profileSaving = true;
    _profileError = null;
    notifyListeners();
    try {
      _profile = await _repo.updateProfile(
        userId,
        fullName: fullName,
        phone: phone.isEmpty ? null : phone,
      );
      return true;
    } catch (e) {
      _profileError = _readable(e);
      return false;
    } finally {
      _profileSaving = false;
      notifyListeners();
    }
  }

  // ── Address actions ───────────────────────────────────────────────

  Future<void> fetchAddresses(String userId) async {
    if (_addresses.isEmpty) {
      _addressesLoading = true;
      notifyListeners();
    }
    try {
      _addresses = await _repo.fetchAddresses(userId);
      _addressesError = null;
    } catch (e) {
      _addressesError = _readable(e);
    } finally {
      _addressesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAddress(String userId, AddressModel address) async {
    _addressesSaving = true;
    _addressesError = null;
    notifyListeners();
    try {
      final created = await _repo.createAddress(userId, address);
      if (address.isDefault) {
        _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
      }
      _addresses = [created, ..._addresses];
      return true;
    } catch (e) {
      _addressesError = _readable(e);
      return false;
    } finally {
      _addressesSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(String userId, AddressModel address) async {
    _addressesSaving = true;
    _addressesError = null;
    notifyListeners();
    try {
      final updated = await _repo.updateAddress(userId, address);
      if (address.isDefault) {
        _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
      }
      _addresses = _addresses
          .map((a) => a.id == updated.id ? updated : a)
          .toList();
      return true;
    } catch (e) {
      _addressesError = _readable(e);
      return false;
    } finally {
      _addressesSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(String userId, String addressId) async {
    _addressesSaving = true;
    _addressesError = null;
    notifyListeners();
    try {
      await _repo.deleteAddress(userId, addressId);
      _addresses = _addresses.where((a) => a.id != addressId).toList();
      return true;
    } catch (e) {
      _addressesError = _readable(e);
      return false;
    } finally {
      _addressesSaving = false;
      notifyListeners();
    }
  }

  void clearErrors() {
    _profileError = null;
    _addressesError = null;
    notifyListeners();
  }

  String _readable(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception:') ? msg.substring(10).trim() : msg;
  }
}
