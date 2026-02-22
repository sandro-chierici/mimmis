// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    HealthResponse(
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$HealthResponseToJson(HealthResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
    };
