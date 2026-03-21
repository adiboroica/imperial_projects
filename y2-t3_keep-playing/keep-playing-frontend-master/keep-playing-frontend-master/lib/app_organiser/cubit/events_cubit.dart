import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/models/event.dart';

class EventsCubit extends Cubit<List<Event>> {
  List<Event> allEvents = [];

  bool allowPastEvents = true;
  bool allowPendingEvents = true;
  bool allowScheduledEvents = true;

  EventsCubit() : super([]);

  Future<void> retrieveEvents() async {
    allEvents = await API.organiser.retrieveEvents();
    updateEventsUsingPreferences();
  }

  void updateEventsUsingPreferences() {
    List<Event> events = [...allEvents];
    events.retainWhere(
      (event) => event.check(
        allowPastEvents: allowPastEvents,
        allowPendingEvents: allowPendingEvents,
        allowScheduledEvents: allowScheduledEvents,
      ),
    );
    emit(events);
  }

  void setAllowPastEventsTo(bool allow) {
    allowPastEvents = allow;
    updateEventsUsingPreferences();
  }

  void setAllowPendingEventsTo(bool allow) {
    allowPendingEvents = allow;
    updateEventsUsingPreferences();
  }

  void setAllowScheduledEventsTo(bool allow) {
    allowScheduledEvents = allow;
    updateEventsUsingPreferences();
  }
}
