import 'package:json_annotation/json_annotation.dart';

part 'cost.g.dart';

@JsonSerializable()
class Cost {
  const Cost({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.total,
    required this.note,
    required this.name,
    required this.refMonth,
    required this.refYear,
    required this.shadowCost
  });

  /// Auto-generated integer PK from the database. 0 when creating (server sets it).
  final int id;
  final String userId;

  /// Optional FK to Category. Empty string means no category.
  final String categoryId;

  /// Amount in minor currency units (e.g. cents).
  final int total;
  final String note;
  final String name;

  /// Reference month (1–12).
  final int refMonth;

  /// Reference year (e.g. 2026).
  final int refYear;

  final bool shadowCost;

  factory Cost.fromJson(Map<String, dynamic> json) => _$CostFromJson(json);

  Map<String, dynamic> toJson() => _$CostToJson(this);
}
