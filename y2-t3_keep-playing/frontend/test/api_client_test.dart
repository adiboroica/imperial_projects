import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

import 'package:keep_playing_frontend/api/client.dart';
import 'package:keep_playing_frontend/api/exceptions.dart';

void main() {
  // ---------------------------------------------------------------
  // ApiException
  // ---------------------------------------------------------------
  group('ApiException', () {
    test('message includes status code', () {
      const e = ApiException(statusCode: 404, body: 'not found');
      expect(e.message, 'Request failed (404)');
    });

    test('toString includes ApiException prefix', () {
      const e = ApiException(statusCode: 500, body: 'error');
      expect(e.toString(), 'ApiException: Request failed (500)');
    });

    test('statusCode and body are accessible', () {
      const e = ApiException(statusCode: 403, body: '{"detail":"forbidden"}');
      expect(e.statusCode, 403);
      expect(e.body, '{"detail":"forbidden"}');
    });
  });

  // ---------------------------------------------------------------
  // ApiClient
  // ---------------------------------------------------------------
  group('ApiClient', () {
    late ApiClient apiClient;

    group('get', () {
      test('returns decoded JSON on success', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('{"key":"value"}', 200);
        });
        apiClient = ApiClient(client: mockClient);

        final result = await apiClient.get('http://test/api');
        expect(result, {'key': 'value'});
      });

      test('throws ApiException on 4xx', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('{"error":"bad request"}', 400);
        });
        apiClient = ApiClient(client: mockClient);

        expect(
          () => apiClient.get('http://test/api'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)),
        );
      });

      test('throws ApiException on 5xx', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('internal error', 500);
        });
        apiClient = ApiClient(client: mockClient);

        expect(
          () => apiClient.get('http://test/api'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)),
        );
      });

      test('throws FormatException on malformed JSON response', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('this is not json', 200);
        });
        apiClient = ApiClient(client: mockClient);

        // get() calls jsonDecode, which throws FormatException on invalid JSON.
        // This is NOT an ApiException — it's an unhandled parse error.
        expect(
          () => apiClient.get('http://test/api'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('post', () {
      test('sends JSON body and returns response on success', () async {
        final mockClient = http_testing.MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.headers['Content-Type'],
              contains('application/json'));
          final body = jsonDecode(request.body);
          expect(body['name'], 'test');
          return http.Response('{"created":true}', 201);
        });
        apiClient = ApiClient(client: mockClient);

        final response =
            await apiClient.post('http://test/api', body: {'name': 'test'});
        expect(response.statusCode, 201);
      });

      test('throws ApiException on 400', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('bad', 400);
        });
        apiClient = ApiClient(client: mockClient);

        expect(
          () => apiClient.post('http://test/api', body: {'x': 1}),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)),
        );
      });
    });

    group('patch', () {
      test('returns response on success', () async {
        final mockClient = http_testing.MockClient((request) async {
          expect(request.method, 'PATCH');
          return http.Response('{"updated":true}', 202);
        });
        apiClient = ApiClient(client: mockClient);

        final response = await apiClient.patch('http://test/api');
        expect(response.statusCode, 202);
      });

      test('throws ApiException on 403', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('forbidden', 403);
        });
        apiClient = ApiClient(client: mockClient);

        expect(
          () => apiClient.patch('http://test/api'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 403)),
        );
      });
    });

    group('delete', () {
      test('returns response on success', () async {
        final mockClient = http_testing.MockClient((request) async {
          expect(request.method, 'DELETE');
          return http.Response('', 204);
        });
        apiClient = ApiClient(client: mockClient);

        final response = await apiClient.delete('http://test/api');
        expect(response.statusCode, 204);
      });

      test('throws ApiException on 404', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('not found', 404);
        });
        apiClient = ApiClient(client: mockClient);

        expect(
          () => apiClient.delete('http://test/api'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)),
        );
      });
    });

    group('postForm', () {
      test('does NOT throw on 4xx (raw response returned)', () async {
        final mockClient = http_testing.MockClient((request) async {
          expect(request.method, 'POST');
          return http.Response('bad credentials', 400);
        });
        apiClient = ApiClient(client: mockClient);

        // postForm returns raw response without _checkResponse
        final response = await apiClient.postForm(
          'http://test/login/',
          fields: {'username': 'x', 'password': 'y'},
        );
        expect(response.statusCode, 400);
      });

      test('returns success response', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('{"token":"abc"}', 200);
        });
        apiClient = ApiClient(client: mockClient);

        final response = await apiClient.postForm(
          'http://test/login/',
          fields: {'username': 'user', 'password': 'pass'},
        );
        expect(response.statusCode, 200);
      });
    });

    group('headers', () {
      test('includes auth header when token is set', () async {
        http.Request? captured;
        final mockClient = http_testing.MockClient((request) async {
          captured = request;
          return http.Response('[]', 200);
        });
        apiClient = ApiClient(client: mockClient);
        apiClient.setToken('mytoken');

        await apiClient.get('http://test/api');

        expect(captured, isNotNull, reason: 'request was never made');
        expect(captured!.headers['Authorization'], 'Token mytoken');
      });

      test('omits auth header when no token', () async {
        http.Request? captured;
        final mockClient = http_testing.MockClient((request) async {
          captured = request;
          return http.Response('[]', 200);
        });
        apiClient = ApiClient(client: mockClient);

        await apiClient.get('http://test/api');

        expect(captured, isNotNull, reason: 'request was never made');
        expect(captured!.headers.containsKey('Authorization'), isFalse);
      });

      test('clears auth header after setToken(null)', () async {
        http.Request? captured;
        final mockClient = http_testing.MockClient((request) async {
          captured = request;
          return http.Response('[]', 200);
        });
        apiClient = ApiClient(client: mockClient);
        apiClient.setToken('token');
        apiClient.setToken(null);

        await apiClient.get('http://test/api');

        expect(captured, isNotNull, reason: 'request was never made');
        expect(captured!.headers.containsKey('Authorization'), isFalse);
      });
    });

    group('getList and getOne', () {
      test('getList parses JSON array', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('[{"id":1},{"id":2}]', 200);
        });
        apiClient = ApiClient(client: mockClient);

        final result = await apiClient.getList(
          'http://test/api',
          (json) => json['id'] as int,
        );
        expect(result, [1, 2]);
      });

      test('getOne parses JSON object', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('{"id":42}', 200);
        });
        apiClient = ApiClient(client: mockClient);

        final result = await apiClient.getOne(
          'http://test/api',
          (json) => json['id'] as int,
        );
        expect(result, 42);
      });
    });
  });
}
