import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/client.dart';
import 'package:keep_playing_frontend/api/coach.dart';
import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/api/users.dart';
import 'package:keep_playing_frontend/app.dart';
import 'package:keep_playing_frontend/repositories/auth_repository.dart';
import 'package:keep_playing_frontend/repositories/coach_repository.dart';
import 'package:keep_playing_frontend/repositories/organiser_repository.dart';
import 'package:keep_playing_frontend/repositories/user_repository.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final apiUsers = ApiUsers(client: apiClient);
  final apiCoach = ApiCoach(client: apiClient);
  final apiOrganiser = ApiOrganiser(client: apiClient);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: apiUsers),
        RepositoryProvider<CoachRepository>.value(value: apiCoach),
        RepositoryProvider<OrganiserRepository>.value(value: apiOrganiser),
        RepositoryProvider<UserRepository>.value(value: apiUsers),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(
          authRepository: context.read<AuthRepository>(),
        ),
        child: const KeepPlayingApp(),
      ),
    ),
  );
}
