import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/models/event.dart';

import 'offers_for_event_view.dart';

class OffersForEventPage extends StatelessWidget {
  final EventsCubit eventsCubit;
  final Event event;

  const OffersForEventPage({
    Key? key,
    required this.eventsCubit,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsCubit>.value(
      value: eventsCubit,
      child: OffersForEventView(event: event),
    );
  }
}
