import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/state/data_state.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/calendar_view.dart';
import 'package:keep_playing_frontend/widgets/error_display.dart';
import 'package:keep_playing_frontend/widgets/event_card.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

import '../offers_page.dart';
import '../past_event/past_event_details_page.dart';
import '../profile/organiser_cubit.dart';
import 'events_cubit.dart';
import 'events_for_day_page.dart';
import 'manage_event_page.dart';
import 'new_event_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool _showCalendar = true;

  @override
  Widget build(BuildContext context) {
    final eventsCubit = context.watch<EventsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_month),
            tooltip: _showCalendar ? 'List view' : 'Calendar view',
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterSwitches(eventsCubit: eventsCubit),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<EventsCubit, DataState<List<Event>>>(
              builder: (context, state) => switch (state) {
                DataInitial() || DataLoading() => const LoadingIndicator(),
                DataError(message: final msg) => ErrorDisplay(
                    message: msg,
                    onRetry: eventsCubit.loadEvents,
                  ),
                DataLoaded(data: final events) =>
                  _showCalendar ? _buildCalendar(events) : _buildList(events),
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Job'),
        onPressed: () => _navigateToNewEvent(context),
      ),
    );
  }

  Widget _buildCalendar(List<Event> events) {
    return CalendarView(
      events: events,
      onDaySelected: (day) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EventsForDayPage(
            day: day,
            eventsCubit: context.read<EventsCubit>(),
            organiserCubit: context.read<OrganiserCubit>(),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Event> events) {
    if (events.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(child: Text('No events to display')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: context.read<EventsCubit>().loadEvents,
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) => _buildEventCard(events[index]),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    if (event.isInThePast) {
      return _PastEventCard(event: event);
    } else if (event.hasCoach) {
      return _ScheduledEventCard(event: event);
    } else {
      return _PendingEventCard(event: event);
    }
  }

  Future<void> _navigateToNewEvent(BuildContext context) async {
    final organiserCubit = context.read<OrganiserCubit>();
    final eventsCubit = context.read<EventsCubit>();

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewEventPage(
          eventsCubit: eventsCubit,
          organiser: organiserCubit.state,
        ),
      ),
    );
    if (created == true) {
      eventsCubit.loadEvents();
    }
  }
}

class _FilterSwitches extends StatelessWidget {
  final EventsCubit eventsCubit;

  const _FilterSwitches({required this.eventsCubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          title: const Text('Past Events'),
          value: eventsCubit.allowPastEvents,
          onChanged: (value) => eventsCubit.setAllowPastEvents(value),
          dense: true,
        ),
        SwitchListTile(
          title: const Text('Pending Events'),
          value: eventsCubit.allowPendingEvents,
          onChanged: (value) => eventsCubit.setAllowPendingEvents(value),
          dense: true,
        ),
        SwitchListTile(
          title: const Text('Scheduled Events'),
          value: eventsCubit.allowScheduledEvents,
          onChanged: (value) => eventsCubit.setAllowScheduledEvents(value),
          dense: true,
        ),
      ],
    );
  }
}

class _PastEventCard extends StatelessWidget {
  final Event event;

  const _PastEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return EventCard(
      event: event,
      leftButton: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PastEventDetailsPage(
                event: event,
                eventsCubit: context.read<EventsCubit>(),
                organiserCubit: context.read<OrganiserCubit>(),
              ),
            ),
          ),
          child: const Text(
            'Details',
            style: TextStyle(fontSize: AppTheme.buttonFontSize, color: Colors.white),
          ),
        ),
      ),
      rightButton: const SizedBox.shrink(),
    );
  }
}

class _ScheduledEventCard extends StatelessWidget {
  final Event event;

  const _ScheduledEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return EventCard(
      event: event,
      leftButton: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.scheduledColor),
          onPressed: null,
          child: const Text(
            'Scheduled',
            style: TextStyle(fontSize: AppTheme.buttonFontSize, color: Colors.white),
          ),
        ),
      ),
      rightButton: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          onPressed: () async {
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => ManageEventPage(
                  event: event,
                  eventsCubit: context.read<EventsCubit>(),
                ),
              ),
            );
            if (changed == true) {
              context.read<EventsCubit>().loadEvents();
            }
          },
          child: const Text(
            'Manage',
            style: TextStyle(fontSize: AppTheme.buttonFontSize, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _PendingEventCard extends StatelessWidget {
  final Event event;

  const _PendingEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return EventCard(
      event: event,
      leftButton: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
          onPressed: () async {
            final accepted = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => OffersPage(
                  event: event,
                  eventsCubit: context.read<EventsCubit>(),
                  organiser: context.read<OrganiserCubit>().state,
                ),
              ),
            );
            if (accepted == true) {
              context.read<EventsCubit>().loadEvents();
            }
          },
          child: Text(
            'Offers (${event.offers.length})',
            style: const TextStyle(fontSize: AppTheme.buttonFontSize, color: Colors.white),
          ),
        ),
      ),
      rightButton: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          onPressed: () async {
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => ManageEventPage(
                  event: event,
                  eventsCubit: context.read<EventsCubit>(),
                ),
              ),
            );
            if (changed == true) {
              context.read<EventsCubit>().loadEvents();
            }
          },
          child: const Text(
            'Manage',
            style: TextStyle(fontSize: AppTheme.buttonFontSize, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
