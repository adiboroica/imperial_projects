import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/models/coach.dart';
import 'package:keep_playing_frontend/models/event/event.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';
import 'package:keep_playing_frontend/widgets/dialogs.dart';
import 'package:keep_playing_frontend/widgets/icons.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';

class RateCoachView extends StatefulWidget {
  final Event event;

  const RateCoachView({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<RateCoachView> createState() => _RateCoachViewState();
}

class _RateCoachViewState extends State<RateCoachView> {
  double _experienceRating = 3;
  double _flexibilityRating = 3;
  double _reliabilityRating = 3;

  @override
  Widget build(BuildContext context) {
    final Widget experienceRatingBar = RatingBar.builder(
      initialRating: _experienceRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemSize: 30.0,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (_, __) => CoachIcons.RATE_ICON,
      onRatingUpdate: (rating) {
        _experienceRating = rating;
      },
    );

    final Widget flexibilityRatingBar = RatingBar.builder(
      initialRating: _flexibilityRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemSize: 30.0,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (_, __) => CoachIcons.RATE_ICON,
      onRatingUpdate: (rating) {
        _flexibilityRating = rating;
      },
    );

    final Widget reliabilityRatingBar = RatingBar.builder(
      initialRating: _reliabilityRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemSize: 30.0,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (_, __) => CoachIcons.RATE_ICON,
      onRatingUpdate: (rating) {
        _reliabilityRating = rating;
      },
    );

    final Widget experienceRow = Container(
      padding: const EdgeInsets.all(DEFAULT_PADDING),
      child: Row(
        children: [
          const Text('Experienced', style: TextStyle(fontSize: 16.0)),
          const Spacer(),
          experienceRatingBar,
        ],
      ),
    );

    final Widget flexibilityRow = Container(
      padding: const EdgeInsets.all(DEFAULT_PADDING),
      child: Row(
        children: [
          const Text('Flexible', style: TextStyle(fontSize: 16.0)),
          const Spacer(),
          flexibilityRatingBar,
        ],
      ),
    );

    final Widget reliabilityRow = Container(
      padding: const EdgeInsets.all(DEFAULT_PADDING),
      child: Row(
        children: [
          const Text('Reliable', style: TextStyle(fontSize: 16.0)),
          const Spacer(),
          reliabilityRatingBar,
        ],
      ),
    );

    void onSendingButtonPressed() {
      const Widget sendRatingDialog = ConfirmationDialog(
        title: 'Are you sure that you want to send this rating?',
      );

      showDialog(
        context: context,
        builder: (_) => sendRatingDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            NavigatorState navigator = Navigator.of(context);
            EventsCubit eventsCubit = BlocProvider.of<EventsCubit>(context);

            CoachNewRating coachNewRating = CoachNewRating(
              experience: _experienceRating.toInt(),
              flexibility: _flexibilityRating.toInt(),
              reliability: _reliabilityRating.toInt(),
            );

            final Response response = await API.organiser.rateEventCoach(
              event: widget.event,
              coachNewRating: coachNewRating,
            );
            if (response.statusCode == HTTP_200_OK) {
              await eventsCubit.retrieveEvents();
              navigator.pop();
              navigator.pop(true);
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

    final Widget sendRatingButton = Container(
      padding: const EdgeInsets.all(BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: SEND_RATING_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onSendingButtonPressed,
        child: const Text('Send Rating'),
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rate Event'),
        ),
        body: ListView(
          children: [
            experienceRow,
            flexibilityRow,
            reliabilityRow,
            sendRatingButton,
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (_) => const ExitDialog(
            title: 'Are you sure that you want to exit?',
            text: 'You didn\'t send the rating.',
          ),
        )) ??
        false;
  }
}
