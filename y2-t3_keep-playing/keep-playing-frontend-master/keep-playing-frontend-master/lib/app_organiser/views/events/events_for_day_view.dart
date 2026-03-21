import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/app_organiser/views/events/widgets/new_job_button.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../cubit/organiser_cubit.dart';
import 'new_event_page.dart';
import 'widgets/event_cards.dart';

class EventsForDayView extends StatelessWidget {
  final DateTime day;

  const EventsForDayView({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final Widget viewOfEvents = BlocBuilder<EventsCubit, List<Event>>(
      builder: (_, __) {
        List<Event> eventsForDay = [
          ...BlocProvider.of<EventsCubit>(context).state
        ];
        eventsForDay.retainWhere((event) =>
            isSameDay(event.date, day) ||
            day.weekday == event.date.weekday &&
                event.isRecurring() &&
                event.date.isBefore(day));

        return ListView.builder(
          itemCount: eventsForDay.length,
          itemBuilder: (_, index) {
            return OrganiserEventCards.getCardForEvent(
                event: eventsForDay[index]);
          },
        );
      },
    );

    final Widget newJobButton = NewJobButton(
      onPressed: () => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NewEventPage(
              eventsCubit: BlocProvider.of<EventsCubit>(context),
              organiserCubit: BlocProvider.of<OrganiserCubit>(context),
              date: day,
            ),
          ),
        ),
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Events on ${DateFormat('dd MMMM').format(day)}'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<EventsCubit>(context).retrieveEvents();
        },
        child: viewOfEvents,
      ),
      floatingActionButton: DateTime.now().isBefore(day)
          ? newJobButton
          : const SizedBox(width: 0, height: 0),
    );
  }
}
