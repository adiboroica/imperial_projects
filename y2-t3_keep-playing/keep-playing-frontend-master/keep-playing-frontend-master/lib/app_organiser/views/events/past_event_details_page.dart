import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/organiser_cubit.dart';
import 'package:keep_playing_frontend/models/event.dart';

import 'past_event_details_view.dart';

class PastEventDetailsPage extends StatelessWidget {
  final EventsCubit eventsCubit;
  final OrganiserCubit organiserCubit;

  final Event event;

  const PastEventDetailsPage({
    Key? key,
    required this.eventsCubit,
    required this.organiserCubit,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventsCubit>.value(value: eventsCubit),
        BlocProvider<OrganiserCubit>.value(value: organiserCubit),
      ],
      child: PastEventDetailsView(event: event),
    );
  }
}
