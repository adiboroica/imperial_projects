import 'package:http/http.dart';

import '../models/event.dart';
import 'client.dart';

class ApiCoach {
  final ApiClient _client;

  ApiCoach({required ApiClient client}) : _client = client;

  Future<List<Event>> getFeedEvents() =>
      _client.getList('/coach/feed/', Event.fromJson);

  Future<List<Event>> getUpcomingJobs() =>
      _client.getList('/coach/upcoming-jobs/', Event.fromJson);

  Future<Response> applyToJob(Event event) =>
      _client.patch('/coach/events/${event.pk}/apply/');

  Future<Response> unapplyFromJob(Event event) =>
      _client.patch('/coach/events/${event.pk}/unapply/');

  Future<Response> cancelJob(Event event) =>
      _client.patch('/coach/events/${event.pk}/cancel/', body: {'coach': false});
}
