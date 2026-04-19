import 'package:http/http.dart';

import 'package:keep_playing_frontend/models/coach_rating.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/models/user.dart';

/// Contract for organiser-side operations: events, coaches, ratings, and preferences.
abstract class OrganiserRepository {
  Future<Organiser> getOrganiser();
  Future<List<Event>> getEvents();
  Future<Response> addEvent({required NewEvent newEvent});
  Future<Response> updateEvent({required Event event, required NewEvent newEvent});
  Future<Response> deleteEvent({required Event event});
  Future<Response> acceptCoach({required Event event, required User coach});
  Future<Response> updateFavourites(List<int> favourites);
  Future<Response> addFavourite(User coach);
  Future<Response> removeFavourite(User coach);
  Future<Response> updateBlocked(List<int> blocked);
  Future<Response> blockCoach(User coach);
  Future<Response> unblockCoach(User coach);
  Future<List<Map<String, dynamic>>> getEventOffers(Event event);
  Future<CoachRating> getCoachRating(User coach);
  Future<Response> rateCoach({required Event event, required CoachNewRating rating});
  Future<Response> updateDefaults({required OrganiserDefaults defaults});
}
