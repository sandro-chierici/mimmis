import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  const Category({required this.id, required this.description});

  /// Human-readable string key, max 50 chars. Chosen by the caller.
  final String id;
  final String description;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
