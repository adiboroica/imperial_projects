import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/event_card.dart';

import '../pages/organiser/events/events_cubit.dart';
import '../pages/organiser/events/manage_event_page.dart';
import '../pages/organiser/offers_page.dart';
import '../pages/organiser/past_event/past_event_details_page.dart';
import '../pages/organiser/profile/organiser_cubit.dart';

class PastEventCard extends StatelessWidget {
  final Event event;

  const PastEventCard({super.key, required this.event});

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

class ScheduledEventCard extends StatelessWidget {
  final Event event;

  const ScheduledEventCard({super.key, required this.event});

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
            final eventsCubit = context.read<EventsCubit>();
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => ManageEventPage(
                  event: event,
                  eventsCubit: eventsCubit,
                ),
              ),
            );
            if (changed == true) {
              eventsCubit.loadEvents();
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

class PendingEventCard extends StatelessWidget {
  final Event event;

  const PendingEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return EventCard(
      event: event,
      leftButton: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
          onPressed: () async {
            final eventsCubit = context.read<EventsCubit>();
            final accepted = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => OffersPage(
                  event: event,
                  eventsCubit: eventsCubit,
                  organiser: context.read<OrganiserCubit>().state,
                ),
              ),
            );
            if (accepted == true) {
              eventsCubit.loadEvents();
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
            final eventsCubit = context.read<EventsCubit>();
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => ManageEventPage(
                  event: event,
                  eventsCubit: eventsCubit,
                ),
              ),
            );
            if (changed == true) {
              eventsCubit.loadEvents();
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
