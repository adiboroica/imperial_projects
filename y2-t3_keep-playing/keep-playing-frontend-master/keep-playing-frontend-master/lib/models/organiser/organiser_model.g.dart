// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organiser_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganiserModel _$OrganiserModelFromJson(Map<String, dynamic> json) =>
    OrganiserModel(
      favourites:
          (json['favourites'] as List<dynamic>).map((e) => e as int).toList(),
      blocked: (json['blocked'] as List<dynamic>).map((e) => e as int).toList(),
      default_sport: json['default_sport'] as String,
      default_role: json['default_role'] as String,
      default_location: json['default_location'] as String,
      default_price: json['default_price'] as int?,
    );

Map<String, dynamic> _$OrganiserModelToJson(OrganiserModel instance) =>
    <String, dynamic>{
      'favourites': instance.favourites,
      'blocked': instance.blocked,
      'default_sport': instance.default_sport,
      'default_role': instance.default_role,
      'default_location': instance.default_location,
      'default_price': instance.default_price,
    };
