import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import 'app_theme.dart';

class EventDetailTiles extends StatelessWidget {
  final Event event;

  const EventDetailTiles({super.key, required this.event});

  static const _titleStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryColor,
  );

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(leading: const Icon(Icons.title), title: Text(event.name, style: _titleStyle)),
        ListTile(leading: const Icon(Icons.sports_soccer), title: const Text('Sport', style: _titleStyle), subtitle: Text(event.sport)),
        ListTile(leading: const Icon(Icons.sports), title: const Text('Role', style: _titleStyle), subtitle: Text(event.role)),
        ListTile(leading: const Icon(Icons.location_on), title: const Text('Location', style: _titleStyle), subtitle: Text(event.location)),
        ListTile(leading: const Icon(Icons.date_range), title: const Text('Date', style: _titleStyle), subtitle: Text(DateFormat('MMMM dd').format(event.date))),
        ListTile(leading: const Icon(Icons.access_time), title: const Text('Start Time', style: _titleStyle), subtitle: Text(_formatTime(event.startTime))),
        ListTile(leading: const Icon(Icons.access_time), title: const Text('End Time', style: _titleStyle), subtitle: Text(_formatTime(event.endTime))),
        ListTile(leading: const Icon(Icons.price_change), title: const Text('Fee per event', style: _titleStyle), subtitle: Text(event.price.toString())),
        const Divider(),
        ListTile(leading: const Icon(Icons.details), title: const Text('Details', style: _titleStyle), subtitle: Text(event.details)),
        const Divider(),
      ],
    );
  }
}
