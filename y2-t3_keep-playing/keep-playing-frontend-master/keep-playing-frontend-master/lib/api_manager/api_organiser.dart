import 'dart:convert';

import 'package:http/http.dart';
import 'package:keep_playing_frontend/models/coach.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/stored_data.dart';

import 'api.dart';

class _ApiOrganiserLinks {
  static const String ORGANISER = "${API.PREFIX}organiser/";

  static Uri organiserLink() => Uri.parse(ORGANISER);

  ////////
  //////// Events
  ////////

  static Uri eventsLink() => Uri.parse("${ORGANISER}events/");

  static Uri addEventLink() => Uri.parse("${ORGANISER}events/");

  static Uri changeEventLink(int pk) => Uri.parse("${ORGANISER}events/$pk/");

  static Uri deleteEventLink(int pk) => Uri.parse("${ORGANISER}events/$pk/");

  static Uri acceptCoachLink({
    required int eventPK,
    required int coachPK,
  }) =>
      Uri.parse("${ORGANISER}events/$eventPK/accept/$coachPK/");

  ////////
  //////// Favourites List
  ////////

  static Uri updateFavouritesLink() => Uri.parse(ORGANISER);

  static Uri addCoachToFavouritesLink(int pk) =>
      Uri.parse("${ORGANISER}add-favourite/$pk/");

  static Uri removeCoachFromFavouritesLink(int pk) =>
      Uri.parse("${ORGANISER}remove-favourite/$pk/");

  ////////
  //////// Blocked List
  ////////

  static Uri updateBlockedLink() => Uri.parse(ORGANISER);

  static Uri blockCoachLink(int pk) => Uri.parse("${ORGANISER}block/$pk/");

  static Uri unblockCoachLink(int pk) => Uri.parse("${ORGANISER}unblock/$pk/");

  ////////
  //////// Coach Rating
  ////////

  static Uri coachRatingLink(int coachPK) =>
      Uri.parse("${ORGANISER}coach-model/$coachPK/");

  static Uri rateCoachEventLink(int eventPK) =>
      Uri.parse("${ORGANISER}vote/$eventPK/");

  ////////
  //////// Defaults
  ////////

  static Uri changeDefaultsLink() => Uri.parse(ORGANISER);
}

class ApiOrganiser {
  final Client client;

  ApiOrganiser({required this.client});

  Future<Organiser> getOrganiser() async {
    String token = StoredData.getLoginToken();

    Response response = await client.get(
      _ApiOrganiserLinks.organiserLink(),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );
    final body = jsonDecode(response.body);

    return Organiser.fromModel(organiserModel: OrganiserModel.fromJson(body));
  }

  // **************************************************************************
  // **************** EVENTS
  // **************************************************************************

  Future<List<Event>> retrieveEvents() async {
    return API.retrieveEvents(_ApiOrganiserLinks.eventsLink());
  }

  Future<Response> addNewEvent({required NewEvent newEvent}) {
    String token = StoredData.getLoginToken();

    return client.post(
      _ApiOrganiserLinks.addEventLink(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(
        newEvent.toJson(),
      ),
    );
  }

  Future<Response> changeEvent({
    required Event event,
    required NewEvent newEvent,
  }) {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiOrganiserLinks.changeEventLink(event.pk),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(
        newEvent.toJson(),
      ),
    );
  }

  Future<Response> cancelEvent({
    required Event event,
  }) {
    return client.delete(_ApiOrganiserLinks.deleteEventLink(event.pk));
  }

  Future<Response> acceptCoach({
    required Event event,
    required User coach,
  }) {
    return client.patch(
      _ApiOrganiserLinks.acceptCoachLink(
        eventPK: event.pk,
        coachPK: coach.pk,
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, dynamic>{"coach": true},
      ),
    );
  }

  // **************************************************************************
  // **************** FAVOURITES LIST
  // **************************************************************************

  Future<Response> updateFavouritesList(List<int> favourites) {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiOrganiserLinks.updateFavouritesLink(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(
        <String, dynamic>{"favourites_ids": favourites},
      ),
    );
  }

  Future<Response> addCoachToFavouritesList(User coach) {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiOrganiserLinks.addCoachToFavouritesLink(coach.pk),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );
  }

  Future<Response> removeCoachFromFavouritesList(User coach) {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiOrganiserLinks.removeCoachFromFavouritesLink(coach.pk),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );
  }

  // **************************************************************************
  // **************** BLOCKED LIST
  // **************************************************************************

  Future<Response> updateBlockedList(List<int> blocked) {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiOrganiserLinks.updateBlockedLink(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(
        <String, dynamic>{"blocked_ids": blocked},
      ),
    );
  }

  Future<Response> blockCoach(User coach) {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiOrganiserLinks.blockCoachLink(coach.pk),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );
  }

  Future<Response> unblockCoach(User coach) {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiOrganiserLinks.unblockCoachLink(coach.pk),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );
  }

  // **************************************************************************
  // **************** COACH RATING
  // **************************************************************************

  Future<CoachRating> getCoachRating(User coach) async {
    String token = StoredData.getLoginToken();

    final Response response = await client.get(
      _ApiOrganiserLinks.coachRatingLink(coach.pk),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
    );
    final body = jsonDecode(response.body);

    return CoachRating.fromModel(coachModel: CoachRatingModel.fromJson(body));
  }

  Future<Response> rateEventCoach({
    required Event event,
    required CoachNewRating coachNewRating,
  }) async {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiOrganiserLinks.rateCoachEventLink(event.pk),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(coachNewRating.toJson()),
    );
  }

  // **************************************************************************
  // **************** DEFAULTS
  // **************************************************************************

  Future<Response> changeDefaults({
    required OrganiserDefaults organiserDefaults,
  }) async {
    String token = StoredData.getLoginToken();

    return client.patch(
      _ApiOrganiserLinks.changeDefaultsLink(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(organiserDefaults.toJson()),
    );
  }
}
