import 'dart:developer';

import '../../core/network/api_client.dart';
import '../models/fixed_cost.dart';

class FixedCostRepository {
  const FixedCostRepository(this._client);

  final ApiClient _client;

  Future<List<FixedCost>> getAll() async {
    try {
      final json = await _client.get('/api/v1/fixed') as List<dynamic>;
      return json
          .cast<Map<String, dynamic>>()
          .map(FixedCost.fromJson)
          .toList();
    } catch (e) {
      log('FixedCostRepository.getAll: $e', name: 'FixedCostRepository');
      rethrow;
    }
  }

  Future<FixedCost> getById(int id) async {
    try {
      final json =
          await _client.get('/api/v1/fixed/$id') as Map<String, dynamic>;
      return FixedCost.fromJson(json);
    } catch (e) {
      log('FixedCostRepository.getById: $e', name: 'FixedCostRepository');
      rethrow;
    }
  }

  /// [fixedCost.id] is ignored by the server on create; the server returns the assigned id.
  Future<FixedCost> create(FixedCost fixedCost) async {
    try {
      final json = await _client.post(
            '/api/v1/fixed',
            fixedCost.toJson(),
          ) as Map<String, dynamic>;
      return FixedCost.fromJson(json);
    } catch (e) {
      log('FixedCostRepository.create: $e', name: 'FixedCostRepository');
      rethrow;
    }
  }

  Future<FixedCost> update(FixedCost fixedCost) async {
    try {
      final json = await _client.put(
            '/api/v1/fixed/${fixedCost.id}',
            fixedCost.toJson(),
          ) as Map<String, dynamic>;
      return FixedCost.fromJson(json);
    } catch (e) {
      log('FixedCostRepository.update: $e', name: 'FixedCostRepository');
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _client.delete('/api/v1/fixed/$id');
    } catch (e) {
      log('FixedCostRepository.delete: $e', name: 'FixedCostRepository');
      rethrow;
    }
  }
}
