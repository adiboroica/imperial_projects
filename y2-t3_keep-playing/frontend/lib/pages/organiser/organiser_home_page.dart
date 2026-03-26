import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

import 'events/events_cubit.dart';
import 'events/events_page.dart';
import 'profile/organiser_cubit.dart';
import 'profile/organiser_profile_page.dart';

class OrganiserHomePage extends StatefulWidget {
  const OrganiserHomePage({super.key});

  @override
  State<OrganiserHomePage> createState() => _OrganiserHomePageState();
}

class _OrganiserHomePageState extends State<OrganiserHomePage> {
  int _selectedIndex = 0;
  Organiser? _organiser;
  String? _error;

  late final ApiOrganiser _apiOrganiser;

  @override
  void initState() {
    super.initState();
    _apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
    _loadOrganiser();
  }

  Future<void> _loadOrganiser() async {
    try {
      final organiser = await _apiOrganiser.getOrganiser();
      if (mounted) {
        setState(() => _organiser = organiser);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load organiser data: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _error = null);
                  _loadOrganiser();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_organiser == null) {
      return const LoadingScreen();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => EventsCubit(apiOrganiser: _apiOrganiser)..loadEvents(),
        ),
        BlocProvider(
          create: (_) => OrganiserCubit(
            apiOrganiser: _apiOrganiser,
            initialOrganiser: _organiser!,
          ),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            EventsPage(),
            OrganiserProfilePage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          indicatorColor: AppTheme.navBarColor,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.event),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
