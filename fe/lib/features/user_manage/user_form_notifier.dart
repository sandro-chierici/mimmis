import 'dart:developer';

import 'package:flutter/widgets.dart';

import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';

class UserFormNotifier extends ChangeNotifier {
  UserFormNotifier({
    required UserRepository userRepo,
    User? initialUser,
  })  : _userRepo = userRepo,
        _initialUser = initialUser {
    if (initialUser != null) {
      nameCtrl.text = initialUser.name;
      surnameCtrl.text = initialUser.surname;
      mailCtrl.text = initialUser.mail;
    }
  }

  final UserRepository _userRepo;
  final User? _initialUser;

  final nameCtrl = TextEditingController();
  final surnameCtrl = TextEditingController();
  final mailCtrl = TextEditingController();

  bool _isSaving = false;
  String? _error;

  bool get isEditing => _initialUser != null;
  bool get isSaving => _isSaving;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Returns `true` on success.
  Future<bool> save() async {
    final name = nameCtrl.text.trim();
    final surname = surnameCtrl.text.trim();
    final mail = mailCtrl.text.trim();

    if (name.isEmpty) {
      _error = 'Name is required';
      notifyListeners();
      return false;
    }
    if (surname.isEmpty) {
      _error = 'Surname is required';
      notifyListeners();
      return false;
    }
    if (mail.isEmpty) {
      _error = 'Email is required';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (isEditing) {
        final initial = _initialUser!;
        await _userRepo.update(
          User(
            userId: initial.userId,
            name: name,
            surname: surname,
            mail: mail,
          ),
        );
      } else {
        await _userRepo.create(
          User(userId: '', name: name, surname: surname, mail: mail),
        );
      }
      return true;
    } catch (e) {
      log('UserFormNotifier.save: $e', name: 'UserFormNotifier');
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    surnameCtrl.dispose();
    mailCtrl.dispose();
    super.dispose();
  }
}
