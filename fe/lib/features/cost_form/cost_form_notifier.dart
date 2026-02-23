import 'dart:developer';

import 'package:flutter/widgets.dart';

import '../../data/models/cost.dart';
import '../../data/models/user.dart';
import '../../data/repositories/cost_repository.dart';

class CostFormNotifier extends ChangeNotifier {
  CostFormNotifier({
    required CostRepository costRepo,
    required User? selectedUser,
    required DateTime selectedDate,
    Cost? initialCost,
  })  : _costRepo = costRepo,
        _selectedUser = selectedUser,
        _selectedDate = selectedDate,
        _initialCost = initialCost {
    if (initialCost != null) {
      nameCtrl.text = initialCost.name;
      noteCtrl.text = initialCost.note;
      totalCtrl.text = (initialCost.total / 100).toStringAsFixed(2);
      _shadowCost = initialCost.shadowCost;
    }
  }

  final CostRepository _costRepo;
  final User? _selectedUser;
  final DateTime _selectedDate;
  final Cost? _initialCost;

  final nameCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final totalCtrl = TextEditingController();

  bool _shadowCost = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _error;

  bool get isEditing => _initialCost != null;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  String? get error => _error;
  bool get shadowCost => _shadowCost;
  String? get selectedUserName => _selectedUser?.name;

  void setShadowCost(bool value) {
    _shadowCost = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Returns `true` if the save was successful.
  Future<bool> save() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      _error = 'Name is required';
      notifyListeners();
      return false;
    }

    final user = _selectedUser;
    if (user == null) {
      _error = 'No user selected';
      notifyListeners();
      return false;
    }

    final totalText = totalCtrl.text.trim().replaceAll(',', '.');
    final totalEuros = double.tryParse(totalText);
    if (totalEuros == null || totalEuros < 0) {
      _error = 'Enter a valid amount';
      notifyListeners();
      return false;
    }

    final totalCents = (totalEuros * 100).round();

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (isEditing) {
        final initial = _initialCost;
        if (initial == null) return false;
        await _costRepo.update(
          Cost(
            id: initial.id,
            userId: initial.userId,
            categoryId: initial.categoryId,
            total: totalCents,
            note: noteCtrl.text.trim(),
            name: name,
            refDay: initial.refDay,
            refMonth: initial.refMonth,
            refYear: initial.refYear,
            shadowCost: _shadowCost,
          ),
        );
      } else {
        await _costRepo.create(
          Cost(
            id: 0,
            userId: user.userId,
            categoryId: '',
            total: totalCents,
            note: noteCtrl.text.trim(),
            name: name,
            refDay: _selectedDate.day,
            refMonth: _selectedDate.month,
            refYear: _selectedDate.year,
            shadowCost: _shadowCost,
          ),
        );
      }
      return true;
    } catch (e) {
      _error = e.toString();
      log('CostFormNotifier.save: $e', name: 'CostFormNotifier');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Returns `true` if the deletion was successful.
  Future<bool> delete() async {
    final initial = _initialCost;
    if (initial == null) return false;

    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      await _costRepo.delete(initial.id);
      return true;
    } catch (e) {
      _error = e.toString();
      log('CostFormNotifier.delete: $e', name: 'CostFormNotifier');
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    noteCtrl.dispose();
    totalCtrl.dispose();
    super.dispose();
  }
}
