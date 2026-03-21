import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'event.dart';

class NewEvent {
  final String name;
  final String location;
  final String details;
  final String sport;
  final String role;

  final DateTime date;
  final DateTime creationStarted;
  final DateTime creationEnded;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TimeOfDay flexibleStartTime;
  final TimeOfDay flexibleEndTime;

  final int price;
  final bool coach;
  final bool recurring;

  NewEvent({
    required this.name,
    required this.location,
    required this.details,
    required this.sport,
    required this.role,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.flexibleStartTime,
    required this.flexibleEndTime,
    required this.price,
    required this.coach,
    required this.recurring,
    required this.creationStarted,
    required this.creationEnded,
  });

  NewEvent.fromEvent(Event event)
      : this(
          name: event.name,
          location: event.location,
          details: event.details,
          sport: event.sport,
          role: event.role,
          date: event.date,
          startTime: event.startTime,
          endTime: event.endTime,
          flexibleStartTime: event.flexibleStartTime,
          flexibleEndTime: event.flexibleEndTime,
          price: event.price,
          coach: event.coach,
          recurring: event.recurring,
          creationStarted: event.creationStarted,
          creationEnded: event.creationEnded,
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "name": name,
        'location': location,
        'details': details,
        'sport': sport,
        'role': role,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'start_time': const DefaultMaterialLocalizations().formatTimeOfDay(
          startTime,
          alwaysUse24HourFormat: true,
        ),
        'end_time': const DefaultMaterialLocalizations().formatTimeOfDay(
          endTime,
          alwaysUse24HourFormat: true,
        ),
        'flexible_start_time':
            const DefaultMaterialLocalizations().formatTimeOfDay(
          flexibleStartTime,
          alwaysUse24HourFormat: true,
        ),
        'flexible_end_time':
            const DefaultMaterialLocalizations().formatTimeOfDay(
          flexibleEndTime,
          alwaysUse24HourFormat: true,
        ),
        'price': price.toString(),
        'coach': coach ? 'True' : 'False',
        'recurring': recurring ? 'True' : 'False',
        'creation_started':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(creationStarted),
        'creation_ended':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(creationEnded),
      };
}
