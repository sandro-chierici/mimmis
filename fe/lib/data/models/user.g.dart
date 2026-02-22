// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  userId: json['userId'] as String,
  name: json['name'] as String,
  surname: json['surname'] as String,
  mail: json['mail'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'surname': instance.surname,
  'mail': instance.mail,
};
