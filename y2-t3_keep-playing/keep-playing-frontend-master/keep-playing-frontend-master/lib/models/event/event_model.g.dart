// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
      pk: json['pk'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      details: json['details'] as String,
      sport: json['sport'] as String,
      role: json['role'] as String,
      date: json['date'] as String,
      creation_started: json['creation_started'] as String,
      creation_ended: json['creation_ended'] as String,
      start_time: json['start_time'] as String,
      end_time: json['end_time'] as String,
      flexible_start_time: json['flexible_start_time'] as String,
      flexible_end_time: json['flexible_end_time'] as String,
      price: json['price'] as int,
      coach: json['coach'] as bool,
      recurring: json['recurring'] as bool,
      coach_user: json['coach_user'] as int?,
      offers: (json['offers'] as List<dynamic>).map((e) => e as int).toList(),
      voted: json['voted'] as bool,
    );

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'name': instance.name,
      'location': instance.location,
      'details': instance.details,
      'sport': instance.sport,
      'role': instance.role,
      'date': instance.date,
      'creation_started': instance.creation_started,
      'creation_ended': instance.creation_ended,
      'start_time': instance.start_time,
      'end_time': instance.end_time,
      'flexible_start_time': instance.flexible_start_time,
      'flexible_end_time': instance.flexible_end_time,
      'price': instance.price,
      'coach': instance.coach,
      'recurring': instance.recurring,
      'coach_user': instance.coach_user,
      'offers': instance.offers,
      'voted': instance.voted,
    };
