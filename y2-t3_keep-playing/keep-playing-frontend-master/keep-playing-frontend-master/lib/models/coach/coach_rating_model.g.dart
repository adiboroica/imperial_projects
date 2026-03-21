// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachRatingModel _$CoachRatingModelFromJson(Map<String, dynamic> json) =>
    CoachRatingModel(
      pk: json['pk'] as int,
      votes: json['votes'] as int,
      experience: json['experience'] as int,
      flexibility: json['flexibility'] as int,
      reliability: json['reliability'] as int,
    );

Map<String, dynamic> _$CoachRatingModelToJson(CoachRatingModel instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'votes': instance.votes,
      'experience': instance.experience,
      'flexibility': instance.flexibility,
      'reliability': instance.reliability,
    };
