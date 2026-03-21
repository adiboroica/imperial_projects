import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/organiser_cubit.dart';

import 'blocked_view.dart';

class BlockedPage extends StatelessWidget {
  final OrganiserCubit organiserCubit;

  const BlockedPage({Key? key, required this.organiserCubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrganiserCubit>.value(
      value: organiserCubit,
      child: const BlockedView(),
    );
  }
}
