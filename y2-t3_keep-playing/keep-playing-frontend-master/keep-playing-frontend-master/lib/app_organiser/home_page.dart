import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/organiser_cubit.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';

import 'views/events_page.dart';
import 'views/profile_page.dart';

class OrganiserHomePage extends StatefulWidget {
  const OrganiserHomePage({Key? key}) : super(key: key);

  @override
  State<OrganiserHomePage> createState() => _OrganiserHomePageState();
}

class _OrganiserHomePageState extends State<OrganiserHomePage> {
  Organiser? organiser;

  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    EventsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    _retrieveOrganiserInformation();

    super.initState();
  }

  void _retrieveOrganiserInformation() async {
    Organiser currentOrganiser = await API.organiser.getOrganiser();

    setState(() {
      organiser = currentOrganiser;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool organiserIsNotLoaded = organiser == null;

    if (organiserIsNotLoaded) {
      return const LoadingScreen();
    }

    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<EventsCubit>(
            create: (_) {
              EventsCubit eventsCubit = EventsCubit();
              eventsCubit.retrieveEvents();
              return eventsCubit;
            },
          ),
          BlocProvider<OrganiserCubit>(
            create: (_) => OrganiserCubit(organiser: organiser!),
          ),
        ],
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          _EventsNavigationButton(),
          _ProfileNavigationButton(),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: BOTTOM_NAVIGATION_BAR_COLOR,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _EventsNavigationButton extends BottomNavigationBarItem {
  const _EventsNavigationButton()
      : super(icon: const Icon(Icons.feed), label: 'Events');
}

class _ProfileNavigationButton extends BottomNavigationBarItem {
  const _ProfileNavigationButton()
      : super(icon: const Icon(Icons.account_box), label: 'Profile');
}
