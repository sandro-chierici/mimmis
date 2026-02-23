// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cost _$CostFromJson(Map<String, dynamic> json) => Cost(
  id: (json['id'] as num).toInt(),
  userId: json['userId'] as String,
  categoryId: json['categoryId'] as String,
  date: DateTime.parse(json['date'] as String),
  total: (json['total'] as num).toInt(),
  note: json['note'] as String,
  name: json['name'] as String,
  refMonth: (json['refMonth'] as num).toInt(),
  refYear: (json['refYear'] as num).toInt(),
  shadowCost: (json['shadowCost'] as bool)
);

Map<String, dynamic> _$CostToJson(Cost instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'categoryId': instance.categoryId,
  'date': instance.date.toIso8601String(),
  'total': instance.total,
  'note': instance.note,
  'name': instance.name,
  'refMonth': instance.refMonth,
  'refYear': instance.refYear,
  'shadowCost': instance.shadowCost,
};
