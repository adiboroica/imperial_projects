import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';

import 'coach_login_page.dart';
import 'coach_profile_page.dart';
import 'feed/feed_page.dart';
import 'upcoming_jobs/upcoming_jobs_page.dart';

class CoachHomePage extends StatefulWidget {
  const CoachHomePage({super.key});

  @override
  State<CoachHomePage> createState() => _CoachHomePageState();
}

class _CoachHomePageState extends State<CoachHomePage> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    FeedPage(),
    UpcomingJobsPage(),
    CoachProfilePage(),
  ];

  static const _titles = <String>[
    'Feed',
    'Upcoming Jobs',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CoachLoginPage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        indicatorColor: AppTheme.navBarColor,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.rss_feed),
            selectedIcon: Icon(Icons.rss_feed, color: Colors.white),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            selectedIcon: Icon(Icons.calendar_today, color: Colors.white),
            label: 'Upcoming Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
