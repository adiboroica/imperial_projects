import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'api/client.dart';
import 'api/users.dart';
import 'app.dart';
import 'state/auth_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final apiUsers = ApiUsers(client: apiClient);

  runApp(
    BlocProvider(
      create: (_) => AuthCubit(
        apiClient: apiClient,
        apiUsers: apiUsers,
      ),
      child: const KeepPlayingApp(),
    ),
  );
}
