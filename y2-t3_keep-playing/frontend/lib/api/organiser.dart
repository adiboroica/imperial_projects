import 'package:http/http.dart';

import 'package:keep_playing_frontend/models/coach_rating.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/repositories/organiser_repository.dart';
import 'package:keep_playing_frontend/api/client.dart';

/// REST implementation of [OrganiserRepository].
class ApiOrganiser implements OrganiserRepository {
  final ApiClient _client;

  ApiOrganiser({required ApiClient client}) : _client = client;

  @override
  Future<Organiser> getOrganiser() =>
      _client.getOne('/organiser/', Organiser.fromJson);

  @override
  Future<List<Event>> getEvents() =>
      _client.getList('/organiser/events/', Event.fromJson);

  @override
  Future<Response> addEvent({required NewEvent newEvent}) =>
      _client.post('/organiser/events/', body: newEvent.toJson());

  @override
  Future<Response> updateEvent({required Event event, required NewEvent newEvent}) =>
      _client.patch('/organiser/events/${event.pk}/', body: newEvent.toJson());

  @override
  Future<Response> deleteEvent({required Event event}) =>
      _client.delete('/organiser/events/${event.pk}/');

  @override
  Future<Response> acceptCoach({required Event event, required User coach}) =>
      _client.patch('/organiser/events/${event.pk}/accept/${coach.pk}/', body: {'coach': true});

  @override
  Future<Response> updateFavourites(List<int> favourites) =>
      _client.patch('/organiser/', body: {'favourites_ids': favourites});

  @override
  Future<Response> addFavourite(User coach) =>
      _client.patch('/organiser/add-favourite/${coach.pk}/');

  @override
  Future<Response> removeFavourite(User coach) =>
      _client.patch('/organiser/remove-favourite/${coach.pk}/');

  @override
  Future<Response> updateBlocked(List<int> blocked) =>
      _client.patch('/organiser/', body: {'blocked_ids': blocked});

  @override
  Future<Response> blockCoach(User coach) =>
      _client.patch('/organiser/block/${coach.pk}/');

  @override
  Future<Response> unblockCoach(User coach) =>
      _client.patch('/organiser/unblock/${coach.pk}/');

  @override
  Future<List<Map<String, dynamic>>> getEventOffers(Event event) async {
    final body = await _client.get('/organiser/events/${event.pk}/offers/');
    return (body as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<CoachRating> getCoachRating(User coach) =>
      _client.getOne('/organiser/coach-model/${coach.pk}/', CoachRating.fromJson);

  @override
  Future<Response> rateCoach({required Event event, required CoachNewRating rating}) =>
      _client.patch('/organiser/vote/${event.pk}/', body: rating.toJson());

  @override
  Future<Response> updateDefaults({required OrganiserDefaults defaults}) =>
      _client.patch('/organiser/', body: defaults.toJson());
}
