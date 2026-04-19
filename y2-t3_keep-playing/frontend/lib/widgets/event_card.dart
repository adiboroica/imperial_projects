import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/utils.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final Widget leftButton;
  final Widget rightButton;

  const EventCard({
    super.key,
    required this.event,
    required this.leftButton,
    required this.rightButton,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(DateFormat('MMMM dd').format(event.date)),
                Text(formatTime(event.startTime)),
                Text(formatTime(event.endTime)),
              ],
            ),
            title: Text(event.name, textAlign: TextAlign.left),
            subtitle: Text(event.location, textAlign: TextAlign.left),
            trailing: Text(event.priceInPounds),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [leftButton, rightButton],
          ),
        ],
      ),
    );
  }
}
