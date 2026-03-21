import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/organiser_cubit.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models_widgets/events_views.dart';

import 'events/events_for_day_page.dart';
import 'events/new_event_page.dart';
import 'events/widgets/event_cards.dart';
import 'events/widgets/new_job_button.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  static const Color ACTIVE_TRACK_COLOR = Colors.lightGreenAccent;
  static const Color ACTIVE_COLOR = Colors.green;

  bool _calendarView = true;

  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: TIMER_DURATION_IN_SECONDS),
      (Timer t) => BlocProvider.of<EventsCubit>(context).retrieveEvents(),
    );
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget appBarButton = _calendarView
        ? ListViewButton(
            onTap: () => {
                  setState(() {
                    _calendarView = !_calendarView;
                  })
                })
        : CalendarViewButton(
            onTap: () => {
                  setState(() {
                    _calendarView = !_calendarView;
                  })
                });

    final List<Widget> optionSelectors = [
      SwitchListTile(
        title: const Text('Past Events'),
        value: BlocProvider.of<EventsCubit>(context).allowPastEvents,
        onChanged: (bool value) {
          setState(() {
            BlocProvider.of<EventsCubit>(context).setAllowPastEventsTo(value);
          });
        },
        activeTrackColor: ACTIVE_TRACK_COLOR,
        activeColor: ACTIVE_COLOR,
      ),
      SwitchListTile(
        title: const Text('Pending Events'),
        value: BlocProvider.of<EventsCubit>(context).allowPendingEvents,
        onChanged: (bool value) {
          setState(() {
            BlocProvider.of<EventsCubit>(context)
                .setAllowPendingEventsTo(value);
          });
        },
        activeTrackColor: ACTIVE_TRACK_COLOR,
        activeColor: ACTIVE_COLOR,
      ),
      SwitchListTile(
        title: const Text('Scheduled Events'),
        value: BlocProvider.of<EventsCubit>(context).allowScheduledEvents,
        onChanged: (bool value) {
          setState(() {
            BlocProvider.of<EventsCubit>(context)
                .setAllowScheduledEventsTo(value);
          });
        },
        activeTrackColor: ACTIVE_TRACK_COLOR,
        activeColor: ACTIVE_COLOR,
      ),
    ];

    final Widget sliverViewOfEvents = BlocBuilder<EventsCubit, List<Event>>(
      builder: (context, state) {
        return _calendarView
            ? SliverList(
                delegate: SliverChildListDelegate(
                  [
                    CalendarViewOfEvents(
                      events: state,
                      onDaySelected: (DateTime day) => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventsForDayPage(
                              eventsCubit:
                                  BlocProvider.of<EventsCubit>(context),
                              organiserCubit:
                                  BlocProvider.of<OrganiserCubit>(context),
                              day: day,
                            ),
                          ),
                        ),
                      },
                      // TODO: Fix this
                      allowPastEvents: true,
                    ),
                  ],
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return OrganiserEventCards.getCardForEvent(
                        event: state[index]);
                  },
                  childCount: state.length,
                ),
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
            ),
          ),
        ),
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [appBarButton],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<EventsCubit>(context).retrieveEvents();
        },
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(optionSelectors),
            ),
            SliverList(
              delegate: SliverChildListDelegate([const Divider()]),
            ),
            sliverViewOfEvents,
          ],
        ),
      ),
      floatingActionButton: newJobButton,
    );
  }
}
