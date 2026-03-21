import 'package:json_annotation/json_annotation.dart';

part 'organiser_model.g.dart';

@JsonSerializable()
class OrganiserModel {
  final List<int> favourites;
  final List<int> blocked;

  final String default_sport;
  final String default_role;
  final String default_location;
  final int? default_price;

  OrganiserModel({
    required this.favourites,
    required this.blocked,
    required this.default_sport,
    required this.default_role,
    required this.default_location,
    required this.default_price,
  });

  factory OrganiserModel.fromJson(Map<String, dynamic> json) =>
      _$OrganiserModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrganiserModelToJson(this);
}
