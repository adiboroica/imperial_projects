import 'package:http/http.dart' as http;

import '../models/event.dart';
import '../models/user.dart';
import 'client.dart';

class ApiUsers {
  final ApiClient _client;

  ApiUsers({required ApiClient client}) : _client = client;

  Future<http.Response> login({required UserLogin userLogin}) {
    return _client.postForm('/login/', fields: {
      'username': userLogin.username,
      'password': userLogin.password,
    });
  }

  Future<User> getCurrentUser() => _client.getOne('/user/', User.fromJson);

  Future<User> getUser(int pk) => _client.getOne('/coach/$pk/', User.fromJson);

  Future<User> getOrganiserOfEvent(Event event) =>
      _client.getOne('/event/${event.pk}/organiser/', User.fromJson);

  Future<List<User>> getAllUsers() => _client.getList('/users/', User.fromJson);

  Future<http.StreamedResponse> signUpAsCoach({required CoachSignUp signUp}) async {
    final request = http.MultipartRequest('POST', Uri.parse('/new_coach/'));
    request.fields['username'] = signUp.username;
    request.fields['password'] = signUp.password;

    if (signUp.qualificationFile != null) {
      final bytes = await signUp.qualificationFile!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'qualification',
        bytes,
        filename: signUp.qualificationFile!.name,
      ));
    }

    return request.send();
  }

  Future<http.Response> signUpAsOrganiser({required OrganiserSignUp signUp}) {
    return _client.post('/new_organiser/', body: signUp.toJson());
  }
}
