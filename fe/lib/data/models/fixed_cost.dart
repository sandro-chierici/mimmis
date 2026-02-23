import 'package:json_annotation/json_annotation.dart';

part 'fixed_cost.g.dart';

@JsonSerializable()
class FixedCost {
  const FixedCost({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.applyDay,
    required this.cost,
    required this.enabled,
    required this.note,
    required this.shadowCost
  });

  /// Auto-generated integer PK from the database. 0 when creating (server sets it).
  final int id;
  final String userId;

  /// Optional FK to Category. Empty string means no category.
  final String categoryId;

  /// Day of the month the cost applies (1–31).
  final int applyDay;

  /// Amount in minor currency units (e.g. cents).
  final int cost;

  /// Whether this recurring cost is currently active.
  final bool enabled;
  final String note;

  final bool shadowCost;

  factory FixedCost.fromJson(Map<String, dynamic> json) =>
      _$FixedCostFromJson(json);

  Map<String, dynamic> toJson() => _$FixedCostToJson(this);
}
