import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/organiser_cubit.dart';
import 'package:keep_playing_frontend/app_organiser/views/events/rate_coach_page.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/models_widgets/event_widgets.dart';
import 'package:keep_playing_frontend/models_widgets/user_widgets.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';
import 'package:keep_playing_frontend/widgets/cards.dart';
import 'package:keep_playing_frontend/widgets/dialogs.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';

class PastEventDetailsView extends StatefulWidget {
  static const String _title = 'Details about past event';

  final Event event;

  const PastEventDetailsView({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<PastEventDetailsView> createState() => _PastEventDetailsViewState();
}

class _PastEventDetailsViewState extends State<PastEventDetailsView> {
  User? _coach;

  bool? _rated;

  bool _coachInformationIsLoaded = false;

  @override
  void initState() {
    _retrieveRatingStatus();
    _retrieveCoachInformation();

    super.initState();
  }

  void _retrieveRatingStatus() {
    setState(() {
      _rated = widget.event.rated;
    });
  }

  void _retrieveCoachInformation() async {
    User? retrievedCoach = widget.event.coachPK == null
        ? null
        : await API.user.getUser(widget.event.coachPK!);

    setState(() {
      _coach = retrievedCoach;
      _coachInformationIsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool ratedStatusIsNotLoaded = _rated == null;
    final bool coachInformationIsNotLoaded = !_coachInformationIsLoaded;

    if (ratedStatusIsNotLoaded || coachInformationIsNotLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(PastEventDetailsView._title),
        ),
        body: LOADING_CIRCLE,
      );
    }

    final Widget blockButton = BlocBuilder<OrganiserCubit, Organiser>(
      builder: (_, state) {
        return state.hasBlockedUser(_coach!)
            ? _UnblockButton(coach: _coach!)
            : _BlockButton(coach: _coach!);
      },
    );

    final Widget favouriteButton = BlocBuilder<OrganiserCubit, Organiser>(
      builder: (_, state) {
        return state.hasBlockedUser(_coach!)
            ? const SizedBox(width: 0, height: 0)
            : (state.hasUserAsAFavourite(_coach!)
                ? _RemoveFromFavouritesButton(coach: _coach!)
                : _AddToFavouritesButton(coach: _coach!));
      },
    );

    final Widget rateButton = _rated!
        ? _RatedButton()
        : _RateButton(
            event: widget.event,
            onRatingGiven: () {
              setState(() {
                _rated = true;
              });
            },
          );

    final Widget coachInformationCard = _coach == null
        ? const Card(
            margin: EdgeInsets.all(CARD_PADDING),
            child: ListTile(
              title: Center(
                child: Text('This event didn\'t have a coach.'),
              ),
            ),
          )
        : Card(
            margin: const EdgeInsets.all(CARD_PADDING),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserInfoListTile(
                  user: _coach!,
                  event: widget.event,
                  userInfoType: UserInfoType.COACH,
                ),
                blockButton,
                favouriteButton,
                rateButton,
              ],
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text(PastEventDetailsView._title),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<OrganiserCubit>(context)
              .retrieveOrganiserInformation();
        },
        child: ListView(
          children: [
            coachInformationCard,
            ...EventWidgets(event: widget.event).getDetailsTilesAboutEvent()
          ],
        ),
      ),
    );
  }
}

// **************************************************************************
// **************** BUTTONS
// **************************************************************************

class _BlockButton extends StatelessWidget {
  final User coach;

  const _BlockButton({required this.coach});

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      const Widget blockDialog = ConfirmationDialog(
        title: 'Are you sure that you want to block this coach?',
      );

      showDialog(
        context: context,
        builder: (_) => blockDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            final NavigatorState navigator = Navigator.of(context);
            OrganiserCubit organiserCubit =
                BlocProvider.of<OrganiserCubit>(context);

            Response response = await API.organiser.blockCoach(coach);
            if (response.statusCode == HTTP_202_ACCEPTED) {
              await organiserCubit.retrieveOrganiserInformation();
              navigator.pop();
            } else {
              navigator.pop();
              showDialog(
                context: context,
                builder: (_) => const RequestFailedDialog(),
                barrierDismissible: false,
              );
            }
          }
        },
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(BUTTON_PADDING, 0, BUTTON_PADDING, 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: BLOCK_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onPressed,
        child: const Text('Block'),
      ),
    );
  }
}

class _UnblockButton extends StatelessWidget {
  final User coach;

  const _UnblockButton({required this.coach});

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      const Widget unblockDialog = ConfirmationDialog(
        title: 'Are you sure that you want to unblock this coach?',
      );

      showDialog(
        context: context,
        builder: (_) => unblockDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            final NavigatorState navigator = Navigator.of(context);
            OrganiserCubit organiserCubit =
                BlocProvider.of<OrganiserCubit>(context);

            Response response = await API.organiser.unblockCoach(coach);
            if (response.statusCode == HTTP_202_ACCEPTED) {
              await organiserCubit.retrieveOrganiserInformation();
              navigator.pop();
            } else {
              navigator.pop();
              showDialog(
                context: context,
                builder: (_) => const RequestFailedDialog(),
                barrierDismissible: false,
              );
            }
          }
        },
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(BUTTON_PADDING, 0, BUTTON_PADDING, 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: UNBLOCK_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onPressed,
        child: const Text('Unblock'),
      ),
    );
  }
}

class _AddToFavouritesButton extends StatelessWidget {
  final User coach;

  const _AddToFavouritesButton({required this.coach});

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      const Widget addCoachAsAFavouriteDialog = ConfirmationDialog(
        title: 'Are you sure that you want to add this coach as a favourite?',
      );

      showDialog(
        context: context,
        builder: (_) => addCoachAsAFavouriteDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            final NavigatorState navigator = Navigator.of(context);
            OrganiserCubit organiserCubit =
                BlocProvider.of<OrganiserCubit>(context);

            Response response =
                await API.organiser.addCoachToFavouritesList(coach);
            if (response.statusCode == HTTP_202_ACCEPTED) {
              await organiserCubit.retrieveOrganiserInformation();
              navigator.pop();
            } else {
              navigator.pop();
              showDialog(
                context: context,
                builder: (_) => const RequestFailedDialog(),
                barrierDismissible: false,
              );
            }
          }
        },
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(BUTTON_PADDING, 0, BUTTON_PADDING, 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onPressed,
        child: const Text('Add Favourite'),
      ),
    );
  }
}

class _RemoveFromFavouritesButton extends StatelessWidget {
  final User coach;

  const _RemoveFromFavouritesButton({required this.coach});

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      const Widget removeCoachAsAFavouriteDialog = ConfirmationDialog(
        title:
            'Are you sure that you want to remove this coach as a favourite?',
      );

      showDialog(
        context: context,
        builder: (_) => removeCoachAsAFavouriteDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            final NavigatorState navigator = Navigator.of(context);
            OrganiserCubit organiserCubit =
                BlocProvider.of<OrganiserCubit>(context);

            Response response =
                await API.organiser.removeCoachFromFavouritesList(coach);
            if (response.statusCode == HTTP_202_ACCEPTED) {
              await organiserCubit.retrieveOrganiserInformation();
              navigator.pop();
            } else {
              navigator.pop();
              showDialog(
                context: context,
                builder: (_) => const RequestFailedDialog(),
                barrierDismissible: false,
              );
            }
          }
        },
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(BUTTON_PADDING, 0, BUTTON_PADDING, 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onPressed,
        child: const Text('Remove Favourite'),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final Event event;
  final VoidCallback onRatingGiven;

  const _RateButton({
    required this.event,
    required this.onRatingGiven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          BUTTON_PADDING, 0, BUTTON_PADDING, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: RATE_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (_) => RateCoachPage(
                eventsCubit: BlocProvider.of<EventsCubit>(context),
                event: event,
              ),
            ),
          )
              .then((value) {
            if (value == true) {
              onRatingGiven();
            }
          });
        },
        child: const Text('Rate'),
      ),
    );
  }
}

class _RatedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          BUTTON_PADDING, 0, BUTTON_PADDING, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: RATED_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () {},
        child: const Text('Rated'),
      ),
    );
  }
}
