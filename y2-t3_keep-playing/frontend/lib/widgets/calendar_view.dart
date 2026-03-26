import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/event.dart';
import 'app_theme.dart';

class CalendarView extends StatefulWidget {
  final List<Event> events;
  final void Function(DateTime day) onDaySelected;

  const CalendarView({
    super.key,
    required this.events,
    required this.onDaySelected,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<Event> _getEventsForDay(DateTime day) {
    return widget.events.where((event) {
      if (isSameDay(day, event.date)) return true;
      return day.weekday == event.date.weekday &&
          event.isRecurring &&
          event.date.isBefore(day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: TableCalendar(
        startingDayOfWeek: StartingDayOfWeek.monday,
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _focusedDay = focusedDay;
              _selectedDay = selectedDay;
            });
          }
          widget.onDaySelected(selectedDay);
        },
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        eventLoader: (day) => _getEventsForDay(day),
      ),
    );
  }
}
