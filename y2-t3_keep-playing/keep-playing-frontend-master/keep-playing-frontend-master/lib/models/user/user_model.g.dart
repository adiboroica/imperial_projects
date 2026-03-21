// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      pk: json['pk'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
      location: json['location'] as String,
      is_coach: json['is_coach'] as bool,
      is_organiser: json['is_organiser'] as bool,
      verified: json['verified'] as bool,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'pk': instance.pk,
      'username': instance.username,
      'email': instance.email,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'location': instance.location,
      'is_coach': instance.is_coach,
      'is_organiser': instance.is_organiser,
      'verified': instance.verified,
    };
