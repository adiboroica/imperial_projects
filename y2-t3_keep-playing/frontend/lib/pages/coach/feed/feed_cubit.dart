import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/repositories/coach_repository.dart';
import 'package:keep_playing_frontend/state/data_state.dart';

class FeedCubit extends Cubit<DataState<List<Event>>> {
  final CoachRepository _coachRepository;

  FeedCubit({required CoachRepository coachRepository})
      : _coachRepository = coachRepository,
        super(const DataInitial());

  Future<void> loadFeed() async {
    emit(const DataLoading());
    try {
      final events = await _coachRepository.getFeedEvents();
      emit(DataLoaded(events));
    } catch (e) {
      emit(DataError(e.toString()));
    }
  }
}
