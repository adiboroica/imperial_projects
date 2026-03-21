import 'package:json_annotation/json_annotation.dart';

part 'coach_rating_model.g.dart';

@JsonSerializable()
class CoachRatingModel {
  final int pk;

  final int votes;
  final int experience;
  final int flexibility;
  final int reliability;

  CoachRatingModel({
    required this.pk,
    required this.votes,
    required this.experience,
    required this.flexibility,
    required this.reliability,
  });

  factory CoachRatingModel.fromJson(Map<String, dynamic> json) =>
      _$CoachRatingModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoachRatingModelToJson(this);
}
