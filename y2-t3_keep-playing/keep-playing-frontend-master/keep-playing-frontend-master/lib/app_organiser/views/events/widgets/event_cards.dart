import 'package:flutter/material.dart';
import 'package:keep_playing_frontend/models/event.dart';

import 'cards/past_event_card.dart';
import 'cards/pending_event_card.dart';
import 'cards/scheduled_event_card.dart';

export 'cards/past_event_card.dart';
export 'cards/pending_event_card.dart';
export 'cards/scheduled_event_card.dart';

class OrganiserEventCards {
  static Widget getCardForEvent({required Event event}) {
    if (event.isInThePast()) {
      return PastEventCard(event: event);
    }
    if (event.hasCoach()) {
      return ScheduledEventCard(event: event);
    }
    return PendingEventCard(event: event);
  }
}
