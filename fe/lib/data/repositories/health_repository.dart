import 'dart:developer';

import '../../core/network/api_client.dart';
import '../models/health_response.dart';

class HealthRepository {
  const HealthRepository(this._client);

  final ApiClient _client;

  Future<HealthResponse> check() async {
    try {
      final json = await _client.get('/health') as Map<String, dynamic>;
      return HealthResponse.fromJson(json);
    } catch (e) {
      log('HealthRepository.check: $e', name: 'HealthRepository');
      rethrow;
    }
  }
}
