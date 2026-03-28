import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/state/data_state.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/error_display.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';
import 'package:keep_playing_frontend/widgets/organiser_event_cards.dart';

import '../profile/organiser_cubit.dart';
import 'events_cubit.dart';
import 'new_event_page.dart';

class EventsForDayPage extends StatelessWidget {
  final DateTime day;
  final EventsCubit eventsCubit;
  final OrganiserCubit organiserCubit;

  const EventsForDayPage({
    super.key,
    required this.day,
    required this.eventsCubit,
    required this.organiserCubit,
  });

  List<Event> _eventsForDay(List<Event> allEvents) {
    return allEvents.where((event) {
      if (isSameDay(event.date, day)) return true;
      return event.date.weekday == day.weekday &&
          event.isRecurring &&
          event.date.isBefore(day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: eventsCubit),
        BlocProvider.value(value: organiserCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(DateFormat('MMMM dd, yyyy').format(day)),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<EventsCubit, DataState<List<Event>>>(
          builder: (context, state) => switch (state) {
            DataInitial() || DataLoading() => const LoadingIndicator(),
            DataError(message: final msg) => ErrorDisplay(
                message: msg,
                onRetry: eventsCubit.loadEvents,
              ),
            DataLoaded(data: final events) => _buildList(context, events),
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('New Job'),
          onPressed: () => _navigateToNewEvent(context),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Event> allEvents) {
    final events = _eventsForDay(allEvents);

    if (events.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(child: Text('No events for this day')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: eventsCubit.loadEvents,
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) => _buildEventCard(context, events[index]),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    if (event.isInThePast) {
      return PastEventCard(event: event);
    } else if (event.hasCoach) {
      return ScheduledEventCard(event: event);
    } else {
      return PendingEventCard(event: event);
    }
  }

  Future<void> _navigateToNewEvent(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewEventPage(
          eventsCubit: eventsCubit,
          organiser: organiserCubit.state,
          initialDate: day,
        ),
      ),
    );
    if (created == true) {
      eventsCubit.loadEvents();
    }
  }
}

