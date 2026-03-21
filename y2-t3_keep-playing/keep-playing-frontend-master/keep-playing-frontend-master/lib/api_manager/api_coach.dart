import 'dart:convert';

import 'package:http/http.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/stored_data.dart';

import 'api.dart';

class _ApiCoachLinks {
  static const String COACH = "${API.PREFIX}coach/";

  ////////
  //////// Events
  ////////

  static Uri feedEventsLink() => Uri.parse("${COACH}feed/");

  static Uri upcomingJobsLink() => Uri.parse("${COACH}upcoming-jobs/");

  ////////
  //////// Jobs
  ////////

  static Uri applyToJobLink(int pk) => Uri.parse("${COACH}events/$pk/apply/");

  static Uri unapplyFromJobLink(int pk) =>
      Uri.parse("${COACH}events/$pk/unapply/");

  static Uri cancelJobLink(int pk) => Uri.parse("${COACH}events/$pk/cancel/");
}

class ApiCoach {
  final Client client;

  ApiCoach({required this.client});

  // **************************************************************************
  // **************** EVENTS
  // **************************************************************************

  Future<List<Event>> retrieveFeedEvents() async {
    return API.retrieveEvents(_ApiCoachLinks.feedEventsLink());
  }

  Future<List<Event>> retrieveUpcomingJobs() async {
    return API.retrieveEvents(_ApiCoachLinks.upcomingJobsLink());
  }

  // **************************************************************************
  // **************** JOBS
  // **************************************************************************

  Future<Response> applyToJob({required Event event}) async {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiCoachLinks.applyToJobLink(event.pk),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );
  }

  Future<Response> unapplyFromJob({required Event event}) async {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiCoachLinks.unapplyFromJobLink(event.pk),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );
  }

  Future<Response> cancelJob({required Event event}) async {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiCoachLinks.cancelJobLink(event.pk),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(<String, dynamic>{"coach": false}),
    );
  }
}
