import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:keep_playing_frontend/api_manager/api_coach.dart';
import 'package:keep_playing_frontend/api_manager/api_organiser.dart';
import 'package:keep_playing_frontend/api_manager/api_users.dart';
import 'package:keep_playing_frontend/stored_data.dart';

import '../models/event.dart';

const int HTTP_200_OK = 200;
const int HTTP_201_CREATED = 201;
const int HTTP_202_ACCEPTED = 202;

class API {
  static const String PREFIX = "https://keep-playing.herokuapp.com/";

  static final Client client = http.Client();

  static ApiCoach coach = ApiCoach(client: client);
  static ApiUsers user = ApiUsers(client: client);
  static ApiOrganiser organiser = ApiOrganiser(client: client);

  static Future<List<Event>> retrieveEvents(Uri link) async {
    String token = StoredData.getLoginToken();

    List<Event> events = [];
    final Response response = await client.get(
      link,
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );
    final body = json.decode(response.body);
    for (var element in body) {
      events.add(Event(eventModel: EventModel.fromJson(element)));
    }
    return events;
  }
}
