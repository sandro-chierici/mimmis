import 'dart:developer';

import '../../core/network/api_client.dart';
import '../models/cost.dart';

class CostRepository {
  const CostRepository(this._client);

  final ApiClient _client;

  Future<List<Cost>> getAll() async {
    try {
      final json = await _client.get('/api/v1/costs') as List<dynamic>;
      return json
          .cast<Map<String, dynamic>>()
          .map(Cost.fromJson)
          .toList();
    } catch (e) {
      log('CostRepository.getAll: $e', name: 'CostRepository');
      rethrow;
    }
  }

  Future<List<Cost>> getAllPerPeriod(int year, int month) async {
    try {
      final json = await _client.get('/api/v1/costs/year/$year/month/$month') as List<dynamic>;
      return json
          .cast<Map<String, dynamic>>()
          .map(Cost.fromJson)
          .toList();
    } catch (e) {
      log('CostRepository.getAllPerPeriod: $e', name: 'CostRepository');
      rethrow;
    }
  }

  Future<List<Cost>> getAllPerUser(String userId, int year, int month) async {
    try {
      final json = await _client.get('/api/v1/costs/user/$userId/year/$year/month/$month') as List<dynamic>;
      return json
          .cast<Map<String, dynamic>>()
          .map(Cost.fromJson)
          .toList();
    } catch (e) {
      log('CostRepository.getAllPerUser: $e', name: 'CostRepository');
      rethrow;
    }
  }

  Future<double> getTotalPerUser(String userId, int year, int month) async { 
    try {
      final json = await _client.get('/api/v1/costs/total/user/$userId/year/$year/month/$month') as Map<String, dynamic>;
      return json['total'] as double;
    } catch (e) {
      log('CostRepository.getTotalPerUser: $e', name: 'CostRepository');
      rethrow;
    }
  }

  Future<double> getTotal(int year, int month) async { 
    try {
      final json = await _client.get('/api/v1/costs/total/year/$year/month/$month') as Map<String, dynamic>;
      return json['total'] as double;
    } catch (e) {
      log('CostRepository.getTotal: $e', name: 'CostRepository');
      rethrow;
    }
  }

  Future<Cost> getById(int id) async {
    try {
      final json =
          await _client.get('/api/v1/costs/$id') as Map<String, dynamic>;
      return Cost.fromJson(json);
    } catch (e) {
      log('CostRepository.getById: $e', name: 'CostRepository');
      rethrow;
    }
  }

  /// [cost.id] is ignored by the server on create; the server returns the assigned id.
  Future<Cost> create(Cost cost) async {
    try {
      final json =
          await _client.post('/api/v1/costs', cost.toJson()) as Map<String, dynamic>;
      return Cost.fromJson(json);
    } catch (e) {
      log('CostRepository.create: $e', name: 'CostRepository');
      rethrow;
    }
  }

  Future<Cost> update(Cost cost) async {
    try {
      final json = await _client.put(
            '/api/v1/costs/${cost.id}',
            cost.toJson(),
          ) as Map<String, dynamic>;
      return Cost.fromJson(json);
    } catch (e) {
      log('CostRepository.update: $e', name: 'CostRepository');
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _client.delete('/api/v1/costs/$id');
    } catch (e) {
      log('CostRepository.delete: $e', name: 'CostRepository');
      rethrow;
    }
  }
}
