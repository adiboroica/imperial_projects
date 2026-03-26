import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/models/organiser.dart';

class OrganiserCubit extends Cubit<Organiser> {
  final ApiOrganiser _apiOrganiser;

  OrganiserCubit({
    required ApiOrganiser apiOrganiser,
    required Organiser initialOrganiser,
  })  : _apiOrganiser = apiOrganiser,
        super(initialOrganiser);

  Future<void> reload() async {
    try {
      final organiser = await _apiOrganiser.getOrganiser();
      emit(organiser);
    } catch (_) {
      // Keep the current state on failure.
    }
  }
}
