import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/repositories/organiser_repository.dart';

class OrganiserCubit extends Cubit<Organiser> {
  final OrganiserRepository _organiserRepository;

  OrganiserCubit({
    required OrganiserRepository organiserRepository,
    required Organiser initialOrganiser,
  })  : _organiserRepository = organiserRepository,
        super(initialOrganiser);

  Future<void> reload() async {
    try {
      final organiser = await _organiserRepository.getOrganiser();
      emit(organiser);
    } catch (_) {
      // Keep the current state on failure.
    }
  }
}
