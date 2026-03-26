import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/coach.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/state/data_state.dart';

class UpcomingJobsCubit extends Cubit<DataState<List<Event>>> {
  final ApiCoach _apiCoach;

  UpcomingJobsCubit({required ApiCoach apiCoach})
      : _apiCoach = apiCoach,
        super(const DataInitial());

  Future<void> loadUpcomingJobs() async {
    emit(const DataLoading());
    try {
      final events = await _apiCoach.getUpcomingJobs();
      emit(DataLoaded(events));
    } catch (e) {
      emit(DataError(e.toString()));
    }
  }
}
