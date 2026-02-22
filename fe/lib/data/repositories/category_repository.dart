import 'dart:developer';

import '../../core/network/api_client.dart';
import '../models/category.dart';

class CategoryRepository {
  const CategoryRepository(this._client);

  final ApiClient _client;

  Future<List<Category>> getAll() async {
    try {
      final json = await _client.get('/api/v1/categories') as List<dynamic>;
      return json
          .cast<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList();
    } catch (e) {
      log('CategoryRepository.getAll: $e', name: 'CategoryRepository');
      rethrow;
    }
  }

  Future<Category> getById(String id) async {
    try {
      final json =
          await _client.get('/api/v1/categories/$id') as Map<String, dynamic>;
      return Category.fromJson(json);
    } catch (e) {
      log('CategoryRepository.getById: $e', name: 'CategoryRepository');
      rethrow;
    }
  }

  /// [category.id] is caller-defined (max 50 chars, not a UUID).
  Future<Category> create(Category category) async {
    try {
      final json = await _client.post(
            '/api/v1/categories',
            category.toJson(),
          ) as Map<String, dynamic>;
      return Category.fromJson(json);
    } catch (e) {
      log('CategoryRepository.create: $e', name: 'CategoryRepository');
      rethrow;
    }
  }

  Future<Category> update(Category category) async {
    try {
      final json = await _client.put(
            '/api/v1/categories/${category.id}',
            category.toJson(),
          ) as Map<String, dynamic>;
      return Category.fromJson(json);
    } catch (e) {
      log('CategoryRepository.update: $e', name: 'CategoryRepository');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.delete('/api/v1/categories/$id');
    } catch (e) {
      log('CategoryRepository.delete: $e', name: 'CategoryRepository');
      rethrow;
    }
  }
}
