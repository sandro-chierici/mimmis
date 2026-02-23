// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_cost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixedCost _$FixedCostFromJson(Map<String, dynamic> json) => FixedCost(
  id: (json['id'] as num).toInt(),
  userId: json['userId'] as String,
  categoryId: json['categoryId'] as String,
  applyDay: (json['applyDay'] as num).toInt(),
  expense: (json['expense'] as num).toInt(),
  enabled: json['enabled'] as bool,
  note: json['note'] as String,
  shadowCost: (json['shadowCost'] as bool)
);

Map<String, dynamic> _$FixedCostToJson(FixedCost instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'categoryId': instance.categoryId,
  'applyDay': instance.applyDay,
  'expense': instance.expense,
  'enabled': instance.enabled,
  'note': instance.note,
  'shadowCost': instance.shadowCost
};
