import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models_widgets/event_widgets.dart';
import 'package:keep_playing_frontend/models_widgets/user_widgets.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';

import '../../manage_event_page.dart';

class ScheduledEventCard extends StatelessWidget {
  final Event event;

  const ScheduledEventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final Widget scheduledButton = Container(
      padding: const EdgeInsets.fromLTRB(BUTTON_PADDING, 0, 0, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: SCHEDULED_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () => {
          showDialog(
            context: context,
            builder: (_) => UserInfoDialog(userInfoType: UserInfoType.COACH)
                .byUserPK(event.coachPK!),
          )
        },
        child: const Text('Scheduled'),
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
      leftButton: scheduledButton,
      rightButton: manageButton,
    );
  }
}
