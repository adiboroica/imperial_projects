import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/models_widgets/event_widgets.dart';
import 'package:keep_playing_frontend/stored_data.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';
import 'package:keep_playing_frontend/widgets/dialogs.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';

import '../../../models/event.dart';
import '../cubits/feed_events_cubit.dart';
import 'details_about_event_page.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: TIMER_DURATION_IN_SECONDS),
      (Timer t) =>
          BlocProvider.of<FeedEventsCubit>(context).retrieveFeedEvents(),
    );
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget viewOfEvents = BlocBuilder<FeedEventsCubit, List<Event>>(
      builder: (_, state) {
        return ListView.builder(
          itemCount: state.length,
          itemBuilder: (_, index) {
            return _FeedEventWidget(
              event: state[index],
              coachPK: StoredData.getCurrentUser().pk,
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<FeedEventsCubit>(context).retrieveFeedEvents();
        },
        child: Center(child: viewOfEvents),
      ),
    );
  }
}

class _FeedEventWidget extends StatelessWidget {
  final Event event;
  final int coachPK;

  const _FeedEventWidget({
    required this.event,
    required this.coachPK,
  });

  @override
  Widget build(BuildContext context) {
    final Widget detailsButton = Container(
      padding: const EdgeInsets.fromLTRB(BUTTON_PADDING, 0, 0, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: DETAILS_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailsAboutEventPage(event: event),
            ),
          );
        },
        child: const Text('Details'),
      ),
    );

    return EventCard(
      event: event,
      leftButton: detailsButton,
      rightButton: event.offers.contains(coachPK)
          ? _UnapplyButton(event: event)
          : _ApplyButton(event: event),
    );
  }
}

// **************************************************************************
// **************** BUTTONS
// **************************************************************************

class _ApplyButton extends StatelessWidget {
  final Event event;

  const _ApplyButton({
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      const Widget applyToJobDialog = ConfirmationDialog(
        title: 'Are you sure that you want to apply?',
      );

      showDialog(
        context: context,
        builder: (_) => applyToJobDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            final NavigatorState navigator = Navigator.of(context);
            final FeedEventsCubit feedEventsCubit =
                BlocProvider.of<FeedEventsCubit>(context);

            final Response response = await API.coach.applyToJob(event: event);
            if (response.statusCode == HTTP_202_ACCEPTED) {
              await feedEventsCubit.retrieveFeedEvents();
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
      padding: const EdgeInsets.fromLTRB(0, 0, BUTTON_PADDING, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APPLY_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onPressed,
        child: const Text('Apply'),
      ),
    );
  }
}

class _UnapplyButton extends StatelessWidget {
  final Event event;

  const _UnapplyButton({
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      const Widget unapplyFromJobDialog = ConfirmationDialog(
        title: 'Are you sure that you want to unapply?',
      );

      showDialog(
        context: context,
        builder: (_) => unapplyFromJobDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            final NavigatorState navigator = Navigator.of(context);
            final FeedEventsCubit feedEventsCubit =
                BlocProvider.of<FeedEventsCubit>(context);

            final Response response =
                await API.coach.unapplyFromJob(event: event);
            if (response.statusCode == HTTP_202_ACCEPTED) {
              await feedEventsCubit.retrieveFeedEvents();
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
      padding: const EdgeInsets.fromLTRB(0, 0, BUTTON_PADDING, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: UNAPPLY_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onPressed,
        child: const Text('Unapply'),
      ),
    );
  }
}
