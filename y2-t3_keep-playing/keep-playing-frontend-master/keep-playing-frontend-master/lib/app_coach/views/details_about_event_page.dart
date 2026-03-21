import 'package:flutter/material.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/models_widgets/event_widgets.dart';
import 'package:keep_playing_frontend/models_widgets/user_widgets.dart';
import 'package:keep_playing_frontend/widgets/cards.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';

class DetailsAboutEventPage extends StatefulWidget {
  static const String _title = 'Details about Event';

  final Event event;

  const DetailsAboutEventPage({
    super.key,
    required this.event,
  });

  @override
  State<DetailsAboutEventPage> createState() => _DetailsAboutEventPageState();
}

class _DetailsAboutEventPageState extends State<DetailsAboutEventPage> {
  User? organiser;

  @override
  void initState() {
    _retrieveOrganiserInformation();

    super.initState();
  }

  void _retrieveOrganiserInformation() async {
    User? eventOrganiser = await API.user.getOrganiserUserOfEvent(widget.event);

    setState(() {
      organiser = eventOrganiser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool organiserInformationIsNotLoaded = organiser == null;

    if (organiserInformationIsNotLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(DetailsAboutEventPage._title),
        ),
        body: LOADING_CIRCLE,
      );
    }

    final Widget organiserInfoCard = Card(
      margin: const EdgeInsets.all(CARD_PADDING),
      child: UserInfoListTile(
        user: organiser!,
        event: widget.event,
        userInfoType: UserInfoType.ORGANISER,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(DetailsAboutEventPage._title),
      ),
      body: ListView(
        children: [
          organiserInfoCard,
          ...EventWidgets(event: widget.event).getDetailsTilesAboutEvent(),
        ],
      ),
    );
  }
}
