import 'package:http/http.dart';

import '../models/coach_rating.dart';
import '../models/event.dart';
import '../models/organiser.dart';
import '../models/user.dart';
import 'client.dart';

class ApiOrganiser {
  final ApiClient _client;

  ApiOrganiser({required ApiClient client}) : _client = client;

  Future<Organiser> getOrganiser() =>
      _client.getOne('/organiser/', Organiser.fromJson);

  // Events
  Future<List<Event>> getEvents() =>
      _client.getList('/organiser/events/', Event.fromJson);

  Future<Response> addEvent({required NewEvent newEvent}) =>
      _client.post('/organiser/events/', body: newEvent.toJson());

  Future<Response> updateEvent({required Event event, required NewEvent newEvent}) =>
      _client.patch('/organiser/events/${event.pk}/', body: newEvent.toJson());

  Future<Response> deleteEvent({required Event event}) =>
      _client.delete('/organiser/events/${event.pk}/');

  Future<Response> acceptCoach({required Event event, required User coach}) =>
      _client.patch('/organiser/events/${event.pk}/accept/${coach.pk}/', body: {'coach': true});

  // Favourites
  Future<Response> updateFavourites(List<int> favourites) =>
      _client.patch('/organiser/', body: {'favourites_ids': favourites});

  Future<Response> addFavourite(User coach) =>
      _client.patch('/organiser/add-favourite/${coach.pk}/');

  Future<Response> removeFavourite(User coach) =>
      _client.patch('/organiser/remove-favourite/${coach.pk}/');

  // Blocked
  Future<Response> updateBlocked(List<int> blocked) =>
      _client.patch('/organiser/', body: {'blocked_ids': blocked});

  Future<Response> blockCoach(User coach) =>
      _client.patch('/organiser/block/${coach.pk}/');

  Future<Response> unblockCoach(User coach) =>
      _client.patch('/organiser/unblock/${coach.pk}/');

  // Rating
  Future<CoachRating> getCoachRating(User coach) =>
      _client.getOne('/organiser/coach-model/${coach.pk}/', CoachRating.fromJson);

  Future<Response> rateCoach({required Event event, required CoachNewRating rating}) =>
      _client.patch('/organiser/vote/${event.pk}/', body: rating.toJson());

  // Defaults
  Future<Response> updateDefaults({required OrganiserDefaults defaults}) =>
      _client.patch('/organiser/', body: defaults.toJson());
}
