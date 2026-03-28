import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';
import 'user.dart';

class Event {
  final int pk;
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
  final int? coachPk;
  final List<int> offers;
  final bool rated;

  const Event({
    required this.pk,
    required this.name,
    required this.location,
    required this.details,
    required this.sport,
    required this.role,
    required this.date,
    required this.creationStarted,
    required this.creationEnded,
    required this.startTime,
    required this.endTime,
    required this.flexibleStartTime,
    required this.flexibleEndTime,
    required this.price,
    required this.coach,
    required this.recurring,
    this.coachPk,
    required this.offers,
    required this.rated,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        pk: json['pk'] as int,
        name: json['name'] as String,
        location: json['location'] as String? ?? '',
        details: json['details'] as String? ?? '',
        sport: json['sport'] as String? ?? '',
        role: json['role'] as String? ?? '',
        date: _parseDate(json['date'] as String),
        creationStarted: _parseDate(json['creation_started'] as String? ?? json['date'] as String),
        creationEnded: _parseDate(json['creation_ended'] as String? ?? json['date'] as String),
        startTime: _parseTime(json['start_time'] as String),
        endTime: _parseTime(json['end_time'] as String),
        flexibleStartTime: _parseTime(json['flexible_start_time'] as String),
        flexibleEndTime: _parseTime(json['flexible_end_time'] as String),
        price: json['price'] as int,
        coach: json['coach'] as bool,
        recurring: json['recurring'] as bool? ?? false,
        coachPk: json['coach_user'] as int?,
        offers: (json['offers'] as List<dynamic>).map((e) => e as int).toList(),
        rated: json['voted'] as bool? ?? false,
      );

  String get priceInPounds => NumberFormat.simpleCurrency(name: 'GBP').format(price);

  DateTime get startTimestamp => DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
  DateTime get endTimestamp => DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

  bool get isInThePast => startTimestamp.isBefore(DateTime.now());
  bool get isInTheFuture => !isInThePast;
  bool get hasCoach => coach;
  bool get isRecurring => recurring;

  bool check({
    required bool allowPastEvents,
    required bool allowPendingEvents,
    required bool allowScheduledEvents,
    DateTime? onDay,
    User? withCoachUser,
  }) {
    var result = true;
    if (!allowPastEvents) result = result && !isInThePast;
    if (!allowPendingEvents) result = result && hasCoach;
    if (!allowScheduledEvents) result = result && !(hasCoach && isInTheFuture);
    if (onDay != null) result = result && isSameDay(date, onDay);
    if (withCoachUser != null) result = result && coachPk == withCoachUser.pk;
    return result;
  }

  static DateTime _parseDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  static TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class NewEvent {
  final String name;
  final String location;
  final String details;
  final String sport;
  final String role;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TimeOfDay flexibleStartTime;
  final TimeOfDay flexibleEndTime;
  final int price;
  final bool coach;
  final bool recurring;
  final DateTime creationStarted;
  final DateTime creationEnded;

  const NewEvent({
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'details': details,
        'sport': sport,
        'role': role,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'start_time': formatTime(startTime),
        'end_time': formatTime(endTime),
        'flexible_start_time': formatTime(flexibleStartTime),
        'flexible_end_time': formatTime(flexibleEndTime),
        'price': price.toString(),
        'coach': coach ? 'True' : 'False',
        'recurring': recurring ? 'True' : 'False',
        'creation_started': DateFormat('yyyy-MM-dd HH:mm:ss').format(creationStarted),
        'creation_ended': DateFormat('yyyy-MM-dd HH:mm:ss').format(creationEnded),
      };
}
