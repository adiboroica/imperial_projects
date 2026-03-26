import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/models/coach_rating.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/exit_guard.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

import '../events/events_cubit.dart';

class RateCoachPage extends StatefulWidget {
  final Event event;
  final EventsCubit eventsCubit;

  const RateCoachPage({
    super.key,
    required this.event,
    required this.eventsCubit,
  });

  @override
  State<RateCoachPage> createState() => _RateCoachPageState();
}

class _RateCoachPageState extends State<RateCoachPage> {
  double _experience = 3;
  double _flexibility = 3;
  double _reliability = 3;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return ExitGuard(
      title: 'Discard Rating?',
      content: 'Your rating will not be saved.',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rate Coach'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _isSubmitting
            ? const LoadingScreen()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Rate the coach for this event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildRatingSection(
                      label: 'Experience',
                      value: _experience,
                      onChanged: (value) => setState(() => _experience = value),
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildRatingSection(
                      label: 'Flexibility',
                      value: _flexibility,
                      onChanged: (value) => setState(() => _flexibility = value),
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildRatingSection(
                      label: 'Reliability',
                      value: _reliability,
                      onChanged: (value) => setState(() => _reliability = value),
                    ),
                    const SizedBox(height: AppTheme.paddingLarge * 2),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _handleSubmit,
                      child: const Text(
                        'Send Rating',
                        style: TextStyle(
                          fontSize: AppTheme.buttonFontSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRatingSection({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Center(
          child: RatingBar.builder(
            initialRating: value,
            minRating: 1,
            maxRating: 5,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(title: 'Submit this rating?'),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    final rating = CoachNewRating(
      experience: _experience.toInt(),
      flexibility: _flexibility.toInt(),
      reliability: _reliability.toInt(),
    );

    try {
      final apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
      final response = await apiOrganiser.rateCoach(
        event: widget.event,
        rating: rating,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
      } else {
        await showDialog(
          context: context,
          builder: (_) => const RequestFailedDialog(),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }
}
