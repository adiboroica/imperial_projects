import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/api/users.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/error_display.dart';
import 'package:keep_playing_frontend/widgets/event_detail_tiles.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';
import 'package:keep_playing_frontend/widgets/user_info_tiles.dart';

import '../events/events_cubit.dart';
import '../profile/organiser_cubit.dart';
import 'rate_coach_page.dart';

class PastEventDetailsPage extends StatefulWidget {
  final Event event;
  final EventsCubit eventsCubit;
  final OrganiserCubit organiserCubit;

  const PastEventDetailsPage({
    super.key,
    required this.event,
    required this.eventsCubit,
    required this.organiserCubit,
  });

  @override
  State<PastEventDetailsPage> createState() => _PastEventDetailsPageState();
}

class _PastEventDetailsPageState extends State<PastEventDetailsPage> {
  User? _coachUser;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoach();
  }

  Future<void> _loadCoach() async {
    if (widget.event.coachPk == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final apiUsers = ApiUsers(client: context.read<AuthCubit>().apiClient);
      final coach = await apiUsers.getUser(widget.event.coachPk!);
      if (mounted) {
        setState(() {
          _coachUser = coach;
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.organiserCubit),
        BlocProvider.value(value: widget.eventsCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.event.name),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingIndicator();

    if (_error != null) {
      return ErrorDisplay(message: _error!, onRetry: _loadCoach);
    }

    return BlocBuilder<OrganiserCubit, dynamic>(
      builder: (context, organiser) {
        return SingleChildScrollView(
          child: Column(
            children: [
              if (_coachUser != null) ...[
                UserInfoListTile(
                  user: _coachUser!,
                  event: widget.event,
                  type: UserInfoType.coach,
                ),
                const Divider(),
                _CoachActionButtons(
                  coach: _coachUser!,
                  event: widget.event,
                  onOrganiserChanged: () => widget.organiserCubit.reload(),
                ),
                const Divider(),
              ],
              EventDetailTiles(event: widget.event),
            ],
          ),
        );
      },
    );
  }
}

class _CoachActionButtons extends StatelessWidget {
  final User coach;
  final Event event;
  final VoidCallback onOrganiserChanged;

  const _CoachActionButtons({
    required this.coach,
    required this.event,
    required this.onOrganiserChanged,
  });

  @override
  Widget build(BuildContext context) {
    final organiser = context.watch<OrganiserCubit>().state;
    final isFav = organiser.isFavourite(coach);
    final isBlocked = organiser.isBlocked(coach);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      child: Wrap(
        spacing: AppTheme.paddingSmall,
        runSpacing: AppTheme.paddingSmall,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? AppTheme.successColor : AppTheme.cancelColor,
            ),
            icon: Icon(
              isBlocked ? Icons.person_add : Icons.block,
              color: Colors.white,
            ),
            label: Text(
              isBlocked ? 'Unblock' : 'Block',
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () => _handleBlockToggle(context, isBlocked),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isFav ? AppTheme.mutedColor : Colors.amber,
            ),
            icon: Icon(
              isFav ? Icons.star_border : Icons.star,
              color: isFav ? Colors.black54 : Colors.white,
            ),
            label: Text(
              isFav ? 'Remove Favourite' : 'Add Favourite',
              style: TextStyle(color: isFav ? Colors.black54 : Colors.white),
            ),
            onPressed: () => _handleFavouriteToggle(context, isFav),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: event.rated ? AppTheme.mutedColor : AppTheme.primaryColor,
            ),
            icon: Icon(
              event.rated ? Icons.check : Icons.rate_review,
              color: event.rated ? Colors.black54 : Colors.white,
            ),
            label: Text(
              event.rated ? 'Rated' : 'Rate',
              style: TextStyle(
                color: event.rated ? Colors.black54 : Colors.white,
              ),
            ),
            onPressed: event.rated ? null : () => _navigateToRate(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBlockToggle(BuildContext context, bool isBlocked) async {
    final action = isBlocked ? 'Unblock' : 'Block';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: '$action ${coach.fullName}?',
      ),
    );
    if (confirmed != true || !context.mounted) return;

    showLoadingDialog(context);

    try {
      final apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
      final response = isBlocked
          ? await apiOrganiser.unblockCoach(coach)
          : await apiOrganiser.blockCoach(coach);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      if (response.statusCode == 200) {
        onOrganiserChanged();
      } else {
        await showDialog(
          context: context,
          builder: (_) => const RequestFailedDialog(),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }

  Future<void> _handleFavouriteToggle(BuildContext context, bool isFav) async {
    final action = isFav ? 'Remove from favourites' : 'Add to favourites';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: '$action?',
      ),
    );
    if (confirmed != true || !context.mounted) return;

    showLoadingDialog(context);

    try {
      final apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
      final response = isFav
          ? await apiOrganiser.removeFavourite(coach)
          : await apiOrganiser.addFavourite(coach);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      if (response.statusCode == 200) {
        onOrganiserChanged();
      } else {
        await showDialog(
          context: context,
          builder: (_) => const RequestFailedDialog(),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }

  Future<void> _navigateToRate(BuildContext context) async {
    final rated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthCubit>(),
          child: RateCoachPage(
            event: event,
            eventsCubit: context.read<EventsCubit>(),
          ),
        ),
      ),
    );
    if (rated == true && context.mounted) {
      context.read<EventsCubit>().loadEvents();
    }
  }
}
