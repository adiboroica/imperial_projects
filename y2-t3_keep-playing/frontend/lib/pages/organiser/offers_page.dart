import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/api/users.dart';
import 'package:keep_playing_frontend/models/coach_rating.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/error_display.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

import 'events/events_cubit.dart';

class _OfferEntry {
  final User user;
  final CoachRating rating;

  const _OfferEntry({required this.user, required this.rating});
}

class OffersPage extends StatefulWidget {
  final Event event;
  final EventsCubit eventsCubit;
  final Organiser organiser;

  const OffersPage({
    super.key,
    required this.event,
    required this.eventsCubit,
    required this.organiser,
  });

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<_OfferEntry>? _offers;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authCubit = context.read<AuthCubit>();
      final apiUsers = ApiUsers(client: authCubit.apiClient);
      final apiOrganiser = ApiOrganiser(client: authCubit.apiClient);

      final entries = await Future.wait(
        widget.event.offers.map((pk) async {
          final user = await apiUsers.getUser(pk);
          final rating = await apiOrganiser.getCoachRating(user);
          return _OfferEntry(user: user, rating: rating);
        }),
      );

      // Sort favourites first.
      entries.sort((a, b) {
        final aFav = widget.organiser.isFavourite(a.user);
        final bFav = widget.organiser.isFavourite(b.user);
        if (aFav && !bFav) return -1;
        if (!aFav && bFav) return 1;
        return 0;
      });

      if (mounted) {
        setState(() {
          _offers = entries;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offers for ${widget.event.name}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingIndicator();

    if (_error != null) {
      return ErrorDisplay(message: _error!, onRetry: _loadOffers);
    }

    final offers = _offers!;
    if (offers.isEmpty) {
      return const Center(child: Text('No offers yet'));
    }

    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) => _OfferCard(
        entry: offers[index],
        isFavourite: widget.organiser.isFavourite(offers[index].user),
        onAccept: () => _handleAccept(offers[index].user),
      ),
    );
  }

  Future<void> _handleAccept(User coach) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Accept ${coach.fullName}?',
      ),
    );
    if (confirmed != true || !mounted) return;

    showLoadingDialog(context);

    try {
      final apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
      await apiOrganiser.acceptCoach(
        event: widget.event,
        coach: coach,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }
}

class _OfferCard extends StatelessWidget {
  final _OfferEntry entry;
  final bool isFavourite;
  final VoidCallback onAccept;

  const _OfferCard({
    required this.entry,
    required this.isFavourite,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.user.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (entry.user.verified)
                  const Tooltip(
                    message: 'Verified',
                    child: Icon(Icons.verified, color: AppTheme.primaryColor),
                  ),
                if (isFavourite)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Tooltip(
                      message: 'Favourite',
                      child: Icon(Icons.star, color: Colors.amber),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            _RatingRow(label: 'Experience', value: entry.rating.experienceAverage),
            _RatingRow(label: 'Flexibility', value: entry.rating.flexibilityAverage),
            _RatingRow(label: 'Reliability', value: entry.rating.reliabilityAverage),
            const SizedBox(height: AppTheme.paddingSmall),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                ),
                onPressed: onAccept,
                child: const Text(
                  'Accept',
                  style: TextStyle(
                    fontSize: AppTheme.buttonFontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final double value;

  const _RatingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          const SizedBox(width: AppTheme.paddingSmall),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 5,
              backgroundColor: AppTheme.mutedColor,
              color: AppTheme.primaryColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: AppTheme.paddingSmall),
          Text(value.toStringAsFixed(1)),
        ],
      ),
    );
  }
}
