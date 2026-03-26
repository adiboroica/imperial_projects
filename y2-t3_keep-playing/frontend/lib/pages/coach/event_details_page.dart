import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/users.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/error_display.dart';
import 'package:keep_playing_frontend/widgets/event_detail_tiles.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';
import 'package:keep_playing_frontend/widgets/user_info_tiles.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  User? _organiser;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganiser();
  }

  Future<void> _loadOrganiser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final apiUsers =
          ApiUsers(client: context.read<AuthCubit>().apiClient);
      final organiser = await apiUsers.getOrganiserOfEvent(widget.event);
      if (mounted) {
        setState(() {
          _organiser = organiser;
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
        title: Text(widget.event.name),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingIndicator();
    }

    if (_error != null) {
      return ErrorDisplay(message: _error!, onRetry: _loadOrganiser);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_organiser != null)
            UserInfoListTile(
              user: _organiser!,
              event: widget.event,
              type: UserInfoType.organiser,
            ),
          const Divider(),
          EventDetailTiles(event: widget.event),
        ],
      ),
    );
  }
}
