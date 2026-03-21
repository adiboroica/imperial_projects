import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/organiser_cubit.dart';

import 'events_for_day_view.dart';

class EventsForDayPage extends StatelessWidget {
  final EventsCubit eventsCubit;
  final OrganiserCubit organiserCubit;

  final DateTime day;

  const EventsForDayPage({
    Key? key,
    required this.eventsCubit,
    required this.organiserCubit,
    required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventsCubit>.value(value: eventsCubit),
        BlocProvider<OrganiserCubit>.value(value: organiserCubit),
      ],
      child: EventsForDayView(day: day),
    );
  }
}
