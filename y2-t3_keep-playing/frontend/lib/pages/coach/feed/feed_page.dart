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
import 'feed_cubit.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final apiCoach = ApiCoach(client: authCubit.apiClient);

    return BlocProvider(
      create: (_) => FeedCubit(apiCoach: apiCoach)..loadFeed(),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView();

  @override
  Widget build(BuildContext context) {
    final feedCubit = context.read<FeedCubit>();

    return BlocBuilder<FeedCubit, DataState<List<Event>>>(
      builder: (context, state) => switch (state) {
        DataInitial() || DataLoading() => const LoadingScreen(),
        DataError(message: final msg) => ErrorDisplay(
            message: msg,
            onRetry: feedCubit.loadFeed,
          ),
        DataLoaded(data: final events) => RefreshIndicator(
            onRefresh: feedCubit.loadFeed,
            child: events.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('No events available')),
                    ],
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) =>
                        _FeedEventCard(event: events[index]),
                  ),
          ),
      },
    );
  }
}

class _FeedEventCard extends StatelessWidget {
  final Event event;

  const _FeedEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final coachPk = context.read<AuthCubit>().currentUser?.pk;
    final hasApplied = coachPk != null && event.offers.contains(coachPk);

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
        child: hasApplied
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cancelColor,
                ),
                onPressed: () => _handleUnapply(context),
                child: const Text(
                  'Unapply',
                  style: TextStyle(
                    fontSize: AppTheme.buttonFontSize,
                    color: Colors.white,
                  ),
                ),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                ),
                onPressed: () => _handleApply(context),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: AppTheme.buttonFontSize,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleApply(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(title: 'Apply to this event?'),
    );
    if (confirmed != true || !context.mounted) return;

    showLoadingDialog(context);

    final apiCoach = ApiCoach(client: context.read<AuthCubit>().apiClient);
    try {
      await apiCoach.applyToJob(event);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      await context.read<FeedCubit>().loadFeed();
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }

  Future<void> _handleUnapply(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          const ConfirmationDialog(title: 'Unapply from this event?'),
    );
    if (confirmed != true || !context.mounted) return;

    showLoadingDialog(context);

    final apiCoach = ApiCoach(client: context.read<AuthCubit>().apiClient);
    try {
      await apiCoach.unapplyFromJob(event);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      await context.read<FeedCubit>().loadFeed();
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
