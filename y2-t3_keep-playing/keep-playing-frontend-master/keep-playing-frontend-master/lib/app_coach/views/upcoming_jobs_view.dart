import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/app_coach/cubits/upcoming_jobs_cubit.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';
import 'package:keep_playing_frontend/widgets/dialogs.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';

import '../../models/event.dart';
import '../../models_widgets/event_widgets.dart';
import 'details_about_event_page.dart';

class UpcomingJobsView extends StatefulWidget {
  const UpcomingJobsView({Key? key}) : super(key: key);

  @override
  State<UpcomingJobsView> createState() => _UpcomingJobsViewState();
}

class _UpcomingJobsViewState extends State<UpcomingJobsView> {
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: TIMER_DURATION_IN_SECONDS),
      (Timer t) =>
          BlocProvider.of<UpcomingJobsCubit>(context).retrieveUpcomingJobs(),
    );
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget viewOfEvents = BlocBuilder<UpcomingJobsCubit, List<Event>>(
      builder: (_, state) {
        return ListView.builder(
          itemCount: state.length,
          itemBuilder: (_, index) {
            return _UpcomingJobWidget(event: state[index]);
          },
        );
      },
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text('Upcoming Jobs'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<UpcomingJobsCubit>(context).retrieveUpcomingJobs();
          },
          child: Center(child: viewOfEvents),
        ));
  }
}

class _UpcomingJobWidget extends StatelessWidget {
  final Event event;

  const _UpcomingJobWidget({required this.event});

  @override
  Widget build(BuildContext context) {
    void onCancelButtonPressed() {
      const Widget cancelJobDialog = ConfirmationDialog(
        title: 'Are you sure that you want to cancel this job?',
      );

      showDialog(
        context: context,
        builder: (_) => cancelJobDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            final NavigatorState navigator = Navigator.of(context);
            final UpcomingJobsCubit upcomingJobsCubit =
                BlocProvider.of<UpcomingJobsCubit>(context);

            final Response response = await API.coach.cancelJob(event: event);
            if (response.statusCode == HTTP_202_ACCEPTED) {
              await upcomingJobsCubit.retrieveUpcomingJobs();
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

    final Widget cancelButton = Container(
      padding: const EdgeInsets.fromLTRB(BUTTON_PADDING, 0, 0, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: CANCEL_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onCancelButtonPressed,
        child: const Text('Cancel'),
      ),
    );

    final Widget detailsButton = Container(
      padding: const EdgeInsets.fromLTRB(0, 0, BUTTON_PADDING, BUTTON_PADDING),
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
      leftButton: cancelButton,
      rightButton: detailsButton,
    );
  }
}
