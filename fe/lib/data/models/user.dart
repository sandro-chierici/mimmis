import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  const User({
    required this.userId,
    required this.name,
    required this.surname,
    required this.mail,
  });

  /// Server-assigned UUIDv7. Empty string when creating (omitted in request).
  final String userId;
  final String name;
  final String surname;
  final String mail;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
