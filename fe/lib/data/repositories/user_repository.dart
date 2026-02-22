import 'dart:developer';

import '../../core/network/api_client.dart';
import '../models/user.dart';

class UserRepository {
  const UserRepository(this._client);

  final ApiClient _client;

  Future<List<User>> getAll() async {
    try {
      final json = await _client.get('/api/v1/users') as List<dynamic>;
      return json
          .cast<Map<String, dynamic>>()
          .map(User.fromJson)
          .toList();
    } catch (e) {
      log('UserRepository.getAll: $e', name: 'UserRepository');
      rethrow;
    }
  }

  Future<User> getById(String id) async {
    try {
      final json =
          await _client.get('/api/v1/users/$id') as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (e) {
      log('UserRepository.getById: $e', name: 'UserRepository');
      rethrow;
    }
  }

  /// [user.userId] is ignored by the server on create.
  Future<User> create(User user) async {
    try {
      final json =
          await _client.post('/api/v1/users', user.toJson()) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (e) {
      log('UserRepository.create: $e', name: 'UserRepository');
      rethrow;
    }
  }

  Future<User> update(User user) async {
    try {
      final json = await _client.put(
            '/api/v1/users/${user.userId}',
            user.toJson(),
          ) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (e) {
      log('UserRepository.update: $e', name: 'UserRepository');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.delete('/api/v1/users/$id');
    } catch (e) {
      log('UserRepository.delete: $e', name: 'UserRepository');
      rethrow;
    }
  }
}
