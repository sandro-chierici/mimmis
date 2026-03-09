import 'dart:developer';

import 'package:flutter/widgets.dart';

import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';

class UserManageNotifier extends ChangeNotifier {
  UserManageNotifier({required UserRepository userRepo})
      : _userRepo = userRepo;

  final UserRepository _userRepo;

  List<User> _users = [];
  bool _isLoading = false;
  String? _error;
  String? _deletingId;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get deletingId => _deletingId;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _userRepo.getAll();
    } catch (e) {
      log('UserManageNotifier.load: $e', name: 'UserManageNotifier');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> delete(String userId) async {
    _deletingId = userId;
    _error = null;
    notifyListeners();

    try {
      await _userRepo.delete(userId);
      _users = _users.where((u) => u.userId != userId).toList();
      return true;
    } catch (e) {
      log('UserManageNotifier.delete: $e', name: 'UserManageNotifier');
      _error = e.toString();
      return false;
    } finally {
      _deletingId = null;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() => load();
}
