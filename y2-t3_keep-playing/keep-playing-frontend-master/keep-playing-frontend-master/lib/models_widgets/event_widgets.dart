import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep_playing_frontend/widgets/cards.dart';
import 'package:keep_playing_frontend/widgets/icons.dart';

import '../constants.dart';
import '../models/event.dart';
import '../widgets/dialogs.dart';

class EventWidgets {
  final Event event;

  EventWidgets({
    required this.event,
  });

  static const TextStyle _textStyleForTitle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: APP_COLOR,
  );

  List<Widget> getDetailsTilesAboutEvent() {
    return <Widget>[
      ListTile(
        leading: EventIcons.NAME_ICON,
        title: Text(event.name, style: _textStyleForTitle),
      ),
      ListTile(
        leading: EventIcons.SPORT_ICON,
        title: const Text('Sport', style: _textStyleForTitle),
        subtitle: Text(event.sport),
      ),
      ListTile(
        leading: EventIcons.ROLE_ICON,
        title: const Text('Role', style: _textStyleForTitle),
        subtitle: Text(event.role),
      ),
      ListTile(
        leading: EventIcons.LOCATION_ICON,
        title: const Text('Location', style: _textStyleForTitle),
        subtitle: Text(event.location),
      ),
      ListTile(
        leading: EventIcons.DATE_ICON,
        title: const Text('Date', style: _textStyleForTitle),
        subtitle: Text(
          DateFormat("MMMM dd").format(event.date),
        ),
      ),
      ListTile(
        leading: EventIcons.START_TIME_ICON,
        title: const Text('Start Time', style: _textStyleForTitle),
        subtitle: Text(
          const DefaultMaterialLocalizations().formatTimeOfDay(
            event.startTime,
            alwaysUse24HourFormat: true,
          ),
        ),
      ),
      ListTile(
        leading: EventIcons.END_TIME_ICON,
        title: const Text('End Time', style: _textStyleForTitle),
        subtitle: Text(
          const DefaultMaterialLocalizations().formatTimeOfDay(
            event.endTime,
            alwaysUse24HourFormat: true,
          ),
        ),
      ),
      ListTile(
        leading: EventIcons.PRICE_ICON,
        title: const Text('Fee per event', style: _textStyleForTitle),
        subtitle: Text(event.price.toString()),
      ),
      const Divider(),
      ListTile(
        leading: EventIcons.DETAILS_ICON,
        title: const Text('Details', style: _textStyleForTitle),
        subtitle: Text(event.details),
      ),
      const Divider()
    ];
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final Widget leftButton;
  final Widget rightButton;

  const EventCard(
      {super.key,
      required this.event,
      required this.leftButton,
      required this.rightButton});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(CARD_PADDING),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(DateFormat("MMMM dd").format(event.date)),
                Text(
                  const DefaultMaterialLocalizations().formatTimeOfDay(
                      event.startTime,
                      alwaysUse24HourFormat: true),
                ),
                Text(
                  const DefaultMaterialLocalizations().formatTimeOfDay(
                      event.endTime,
                      alwaysUse24HourFormat: true),
                ),
              ],
            ),
            title: Text(event.name, textAlign: TextAlign.left),
            subtitle: Text(event.location, textAlign: TextAlign.left),
            trailing: Text(event.getPriceInPounds()),
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

class EventDetailsDialog extends StatelessWidget {
  final Event event;
  final List<Widget> widgetsAtTheEnd;

  const EventDetailsDialog({
    Key? key,
    required this.event,
    required this.widgetsAtTheEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(DIALOG_PADDING),
      title: Center(
        child: Text(
          event.name,
          style: EventWidgets._textStyleForTitle,
          textScaleFactor: 1.5,
        ),
      ),
      children: [
        ...EventWidgets(event: event).getDetailsTilesAboutEvent(),
        ...widgetsAtTheEnd,
      ],
    );
  }
}
