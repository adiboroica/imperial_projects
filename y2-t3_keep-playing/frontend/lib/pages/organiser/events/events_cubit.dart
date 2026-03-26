import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/state/data_state.dart';

class EventsCubit extends Cubit<DataState<List<Event>>> {
  final ApiOrganiser _apiOrganiser;

  List<Event> _allEvents = [];
  bool _allowPastEvents = true;
  bool _allowPendingEvents = true;
  bool _allowScheduledEvents = true;

  bool get allowPastEvents => _allowPastEvents;
  bool get allowPendingEvents => _allowPendingEvents;
  bool get allowScheduledEvents => _allowScheduledEvents;

  EventsCubit({required ApiOrganiser apiOrganiser})
      : _apiOrganiser = apiOrganiser,
        super(const DataInitial());

  Future<void> loadEvents() async {
    emit(const DataLoading());
    try {
      _allEvents = await _apiOrganiser.getEvents();
      _emitFiltered();
    } catch (e) {
      emit(DataError(e.toString()));
    }
  }

  void setAllowPastEvents(bool value) {
    _allowPastEvents = value;
    _emitFiltered();
  }

  void setAllowPendingEvents(bool value) {
    _allowPendingEvents = value;
    _emitFiltered();
  }

  void setAllowScheduledEvents(bool value) {
    _allowScheduledEvents = value;
    _emitFiltered();
  }

  void _emitFiltered() {
    final filtered = _allEvents
        .where((event) => event.check(
              allowPastEvents: _allowPastEvents,
              allowPendingEvents: _allowPendingEvents,
              allowScheduledEvents: _allowScheduledEvents,
            ))
        .toList();
    emit(DataLoaded(filtered));
  }
}
