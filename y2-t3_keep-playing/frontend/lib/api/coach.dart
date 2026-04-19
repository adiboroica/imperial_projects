import 'package:http/http.dart';

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/repositories/coach_repository.dart';
import 'package:keep_playing_frontend/api/client.dart';

/// REST implementation of [CoachRepository].
class ApiCoach implements CoachRepository {
  final ApiClient _client;

  ApiCoach({required ApiClient client}) : _client = client;

  @override
  Future<List<Event>> getFeedEvents() =>
      _client.getList('/coach/feed/', Event.fromJson);

  @override
  Future<List<Event>> getUpcomingJobs() =>
      _client.getList('/coach/upcoming-jobs/', Event.fromJson);

  @override
  Future<Response> applyToJob(Event event) =>
      _client.patch('/coach/events/${event.pk}/apply/');

  @override
  Future<Response> unapplyFromJob(Event event) =>
      _client.patch('/coach/events/${event.pk}/unapply/');

  @override
  Future<Response> cancelJob(Event event) =>
      _client.patch('/coach/events/${event.pk}/cancel/', body: {'coach': false});
}
