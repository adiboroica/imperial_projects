import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/app_organiser/views/events/offers_for_event_page.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models_widgets/event_widgets.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';

import '../../manage_event_page.dart';

class PendingEventCard extends StatelessWidget {
  final Event event;

  const PendingEventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final Widget offersButton = Container(
      padding: const EdgeInsets.fromLTRB(BUTTON_PADDING, 0, 0, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: event.offers.isEmpty
              ? NO_OFFERS_BUTTON_COLOR
              : AT_LEAST_ONE_OFFER_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () {
          if (event.offers.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OffersForEventPage(
                  eventsCubit: BlocProvider.of<EventsCubit>(context),
                  event: event,
                ),
              ),
            );
          }
        },
        child: Text(
          event.offers.isEmpty
              ? 'No Offers'
              : 'Offers (${event.offers.length})',
        ),
      ),
    );

    final Widget manageButton = Container(
      padding: const EdgeInsets.fromLTRB(0, 0, BUTTON_PADDING, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: MANAGE_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ManageEventPage(
                eventsCubit: BlocProvider.of<EventsCubit>(context),
                event: event,
              ),
            ),
          ),
        },
        child: const Text('Manage'),
      ),
    );

    return EventCard(
      event: event,
      leftButton: offersButton,
      rightButton: manageButton,
    );
  }
}
