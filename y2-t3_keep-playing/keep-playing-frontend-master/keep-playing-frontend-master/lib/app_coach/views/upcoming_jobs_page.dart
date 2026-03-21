import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/app_coach/cubits/upcoming_jobs_cubit.dart';

import 'upcoming_jobs_view.dart';

class UpcomingJobsPage extends StatelessWidget {
  const UpcomingJobsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        UpcomingJobsCubit upcomingJobsCubit = UpcomingJobsCubit();
        upcomingJobsCubit.retrieveUpcomingJobs();
        return upcomingJobsCubit;
      },
      child: const UpcomingJobsView(),
    );
  }
}
