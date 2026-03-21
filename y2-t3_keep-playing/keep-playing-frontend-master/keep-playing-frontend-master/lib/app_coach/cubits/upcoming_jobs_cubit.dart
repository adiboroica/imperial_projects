import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/models/event.dart';

class UpcomingJobsCubit extends Cubit<List<Event>> {
  UpcomingJobsCubit() : super([]);

  Future<void> retrieveUpcomingJobs() async {
    List<Event> retrievedEvents = await API.coach.retrieveUpcomingJobs();
    emit(retrievedEvents);
  }
}
