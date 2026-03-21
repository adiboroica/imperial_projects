import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/models/event.dart';

class FeedEventsCubit extends Cubit<List<Event>> {
  FeedEventsCubit() : super([]);

  Future<void> retrieveFeedEvents() async {
    List<Event> retrievedEvents = await API.coach.retrieveFeedEvents();
    emit(retrievedEvents);
  }
}
