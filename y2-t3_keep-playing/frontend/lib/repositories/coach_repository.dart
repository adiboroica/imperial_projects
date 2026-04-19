import 'package:http/http.dart';

import 'package:keep_playing_frontend/models/event.dart';

/// Contract for coach-side operations: feed, jobs, and applications.
abstract class CoachRepository {
  Future<List<Event>> getFeedEvents();
  Future<List<Event>> getUpcomingJobs();
  Future<Response> applyToJob(Event event);
  Future<Response> unapplyFromJob(Event event);
  Future<Response> cancelJob(Event event);
}
