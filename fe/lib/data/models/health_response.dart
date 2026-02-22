import 'package:json_annotation/json_annotation.dart';

part 'health_response.g.dart';

@JsonSerializable()
class HealthResponse {
  const HealthResponse({required this.status, required this.timestamp});

  final String status;
  final DateTime timestamp;

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);
}
