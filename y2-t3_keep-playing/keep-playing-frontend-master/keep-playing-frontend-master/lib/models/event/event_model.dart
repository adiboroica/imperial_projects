import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

@JsonSerializable()
class EventModel {
  final int pk;
  final String name;
  final String location;
  final String details;
  final String sport;
  final String role;

  final String date;
  final String creation_started;
  final String creation_ended;
  final String start_time;
  final String end_time;
  final String flexible_start_time;
  final String flexible_end_time;

  final int price;
  final bool coach;
  final bool recurring;

  final int? coach_user;

  final List<int> offers;

  final bool voted;

  EventModel({
    required this.pk,
    required this.name,
    required this.location,
    required this.details,
    required this.sport,
    required this.role,
    required this.date,
    required this.creation_started,
    required this.creation_ended,
    required this.start_time,
    required this.end_time,
    required this.flexible_start_time,
    required this.flexible_end_time,
    required this.price,
    required this.coach,
    required this.recurring,
    this.coach_user,
    required this.offers,
    required this.voted,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  DateTime getDate() {
    final splitDate = date.split('-');
    return DateTime(
      int.parse(splitDate[0]),
      int.parse(splitDate[1]),
      int.parse(splitDate[2]),
    );
  }

  DateTime getCreationStarted() {
    final splitDate = date.split('-');
    return DateTime(
      int.parse(splitDate[0]),
      int.parse(splitDate[1]),
      int.parse(splitDate[2]),
    );
  }

  DateTime getCreationEnded() {
    final splitDate = date.split('-');
    return DateTime(
      int.parse(splitDate[0]),
      int.parse(splitDate[1]),
      int.parse(splitDate[2]),
    );
  }

  TimeOfDay getStartTime() {
    return _getTimeOfDayFromString(start_time);
  }

  TimeOfDay getEndTime() {
    return _getTimeOfDayFromString(end_time);
  }

  TimeOfDay getFlexibleStartTime() {
    return _getTimeOfDayFromString(flexible_start_time);
  }

  TimeOfDay getFlexibleEndTime() {
    return _getTimeOfDayFromString(flexible_end_time);
  }

  TimeOfDay _getTimeOfDayFromString(String time) {
    final splitEndTime = time.split(':');
    return TimeOfDay(
      hour: int.parse(splitEndTime[0]),
      minute: int.parse(splitEndTime[1]),
    );
  }
}
