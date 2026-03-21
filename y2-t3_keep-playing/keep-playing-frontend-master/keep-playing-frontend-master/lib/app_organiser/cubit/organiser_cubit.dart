import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/models/organiser.dart';

class OrganiserCubit extends Cubit<Organiser> {
  OrganiserCubit({required Organiser organiser}) : super(organiser);

  Future<void> retrieveOrganiserInformation() async {
    Organiser organiser = await API.organiser.getOrganiser();
    emit(organiser);
  }
}
