import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/coach.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/state/data_state.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/error_display.dart';
import 'package:keep_playing_frontend/widgets/event_card.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

import '../event_details_page.dart';
import 'upcoming_jobs_cubit.dart';

class UpcomingJobsPage extends StatelessWidget {
  const UpcomingJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final apiCoach = ApiCoach(client: authCubit.apiClient);

    return BlocProvider(
      create: (_) => UpcomingJobsCubit(apiCoach: apiCoach)..loadUpcomingJobs(),
      child: const _UpcomingJobsView(),
    );
  }
}

class _UpcomingJobsView extends StatelessWidget {
  const _UpcomingJobsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UpcomingJobsCubit>();

    return BlocBuilder<UpcomingJobsCubit, DataState<List<Event>>>(
      builder: (context, state) => switch (state) {
        DataInitial() || DataLoading() => const LoadingScreen(),
        DataError(message: final msg) => ErrorDisplay(
            message: msg,
            onRetry: cubit.loadUpcomingJobs,
          ),
        DataLoaded(data: final events) => RefreshIndicator(
            onRefresh: cubit.loadUpcomingJobs,
            child: events.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('No upcoming jobs')),
                    ],
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) =>
                        _UpcomingJobCard(event: events[index]),
                  ),
          ),
      },
    );
  }
}

class _UpcomingJobCard extends StatelessWidget {
  final Event event;

  const _UpcomingJobCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return EventCard(
      event: event,
      leftButton: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailsPage(event: event),
            ),
          ),
          child: const Text(
            'Details',
            style: TextStyle(
              fontSize: AppTheme.buttonFontSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
      rightButton: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.cancelColor,
          ),
          onPressed: () => _handleCancel(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: AppTheme.buttonFontSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(title: 'Cancel this job?'),
    );
    if (confirmed != true || !context.mounted) return;

    showLoadingDialog(context);

    final apiCoach = ApiCoach(client: context.read<AuthCubit>().apiClient);
    try {
      await apiCoach.cancelJob(event);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      await context.read<UpcomingJobsCubit>().loadUpcomingJobs();
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }
}
