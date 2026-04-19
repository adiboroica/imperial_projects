import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:keep_playing_frontend/utils.dart';
import 'package:keep_playing_frontend/models/user.dart';

/// Immutable event with computed temporal properties, recurrence logic, and multi-filter support.
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
  final DateTime? recurringEndDate;
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
    this.recurringEndDate,
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
        recurringEndDate: json['recurring_end_date'] != null
            ? DateTime.parse(json['recurring_end_date'] as String)
            : null,
        coachPk: json['coach_user'] as int?,
        offers: (json['offers'] as List<dynamic>).map((e) => e as int).toList(),
        rated: json['voted'] as bool? ?? false,
      );

  /// Format price as GBP with currency symbol.
  String get priceInPounds => NumberFormat.simpleCurrency(name: 'GBP').format(price);

  DateTime get startTimestamp => DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
  DateTime get endTimestamp => DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

  bool get isInThePast {
    if (isRecurring) {
      if (recurringEndDate == null) return false;
      return recurringEndDate!.isBefore(DateUtils.dateOnly(DateTime.now()));
    }
    // Match backend `is_event_concluded`: event is past once its end time has
    // passed, not once it starts. Otherwise an in-progress event shows as past.
    return endTimestamp.isBefore(DateTime.now());
  }

  bool get isInTheFuture => !isInThePast;
  bool get hasCoach => coach;
  bool get isRecurring => recurring;

  /// Whether this event (or any recurrence) falls on [day].
  bool occursOn(DateTime day) {
    if (isSameDay(date, day)) return true;
    if (!isRecurring) return false;
    if (date.isAfter(day)) return false;
    if (recurringEndDate != null && day.isAfter(recurringEndDate!)) return false;
    return day.weekday == date.weekday;
  }

  /// Applies multiple optional filters; returns true if the event passes all.
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
    if (onDay != null) result = result && occursOn(onDay);
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

/// Outbound payload for creating or updating an event.
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
  final DateTime? recurringEndDate;
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
    this.recurringEndDate,
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
          recurringEndDate: event.recurringEndDate,
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
        'price': price,
        'coach': coach,
        'recurring': recurring,
        if (recurringEndDate != null)
          'recurring_end_date': DateFormat('yyyy-MM-dd').format(recurringEndDate!),
        'creation_started': DateFormat('yyyy-MM-dd HH:mm:ss').format(creationStarted),
        'creation_ended': DateFormat('yyyy-MM-dd HH:mm:ss').format(creationEnded),
      };
}
