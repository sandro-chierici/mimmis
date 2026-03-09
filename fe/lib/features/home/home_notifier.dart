import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/cost.dart';
import '../../data/models/user.dart';
import '../../data/repositories/cost_repository.dart';
import '../../data/repositories/user_repository.dart';

const _kSelectedUserKey = 'selected_user_id';

class HomeNotifier extends ChangeNotifier {
  HomeNotifier({
    required UserRepository userRepo,
    required CostRepository costRepo,
    required SharedPreferences prefs,
  })  : _userRepo = userRepo,
        _costRepo = costRepo,
        _prefs = prefs;

  final UserRepository _userRepo;
  final CostRepository _costRepo;
  final SharedPreferences _prefs;

  // ── State ──────────────────────────────────────────────────────────────────

  List<User> _users = [];
  List<Cost> _costs = [];
  User? _selectedUser;
  bool _isLoading = false;
  String? _error;

  /// The date used for all cost filters AND as default when adding a new cost.
  /// Starts at today; the user can change day, month or year independently.
  DateTime _selectedDate = DateTime.now();

  // ── Getters ────────────────────────────────────────────────────────────────

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  /// Sum of costs for the selected user in the selected refMonth/refYear.
  int get userMonthTotal {
    if (_selectedUser == null) return 0;
    return _costs
        .where((c) =>
            c.userId == _selectedUser!.userId &&
            c.refMonth == _selectedDate.month &&
            c.refYear == _selectedDate.year)
        .fold(0, (sum, c) => sum + c.total);
  }

  /// Fair share: total of ALL users for the selected month ÷ number of users.
  int get fairShare {
    if (_users.isEmpty) return 0;
    final total = _costs
        .where((c) =>
            c.refMonth == _selectedDate.month &&
            c.refYear == _selectedDate.year)
        .fold(0, (sum, c) => sum + c.total);
    return total ~/ _users.length;
  }

  /// How much the selected user is over/under the fair share.
  /// Positive → spent more; negative → spent less (is owed).
  int get diff => userMonthTotal - fairShare;

  /// Initialise: load users + costs, restore persisted user selection.
  Future<void> init() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _userRepo.getAll(),
        _costRepo.getAllPerPeriod(_selectedDate.year, _selectedDate.month),
      ]);
      _users = results[0] as List<User>;
      _costs = results[1] as List<Cost>;

      final savedId = _prefs.getString(_kSelectedUserKey);
      if (savedId != null) {
        _selectedUser = _users.cast<User?>().firstWhere(
              (u) => u?.userId == savedId,
              orElse: () => null,
            );
      }
      // Fall back to first user when nothing is persisted.
      _selectedUser ??= _users.isNotEmpty ? _users.first : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      log('HomeNotifier.init: $e', name: 'HomeNotifier');
    } finally {


      _setLoading(false);
    }
  }

  /// Refresh both users and costs from the network.
  Future<void> refresh() => init();

  /// Reload only the user list (e.g. after User Manager makes changes).
  Future<void> reloadUsers() async {
    _setLoading(true);
    try {
      _users = await _userRepo.getAll();
      // Re-validate that the selected user still exists.
      if (_selectedUser != null) {
        _selectedUser = _users.cast<User?>().firstWhere(
          (u) => u?.userId == _selectedUser!.userId,
          orElse: () => null,
        );
      }
      _selectedUser ??= _users.isNotEmpty ? _users.first : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      log('HomeNotifier.reloadUsers: $e', name: 'HomeNotifier');
    } finally {
      _setLoading(false);
    }
  }

  /// Reload only costs (e.g. after adding a new cost entry).
  Future<void> reloadCosts() async {
    _setLoading(true);
    try {
      _costs = await _costRepo.getAllPerPeriod(_selectedDate.year, _selectedDate.month);
      _error = null;
    } catch (e) {
      _error = e.toString();
      log('HomeNotifier.reloadCosts: $e', name: 'HomeNotifier');
    } finally {
      _setLoading(false);
    }
  }

  /// Persist the selected user and reload costs for the new selection.
  Future<void> selectUser(User user) async {
    _selectedUser = user;
    _prefs.setString(_kSelectedUserKey, user.userId);
    notifyListeners();
    await reloadCosts();
  }

  /// Update the selected date (day, month or year independently).
  /// All cost filters and the default date for new costs use this value.
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Last 3 costs for the selected user in the selected reference month/year,
  /// sorted newest-first.
  List<Cost> recentCosts() {
    if (_selectedUser == null) return [];
    final filtered = _costs
        .where((c) =>
            c.userId == _selectedUser!.userId &&
            c.refMonth == _selectedDate.month &&
            c.refYear == _selectedDate.year)
        .toList();
      
    return filtered;
  }
}
