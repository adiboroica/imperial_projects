import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/state/auth_storage.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }
}

void main() {
  late AuthStorage storage;
  late _FakeSecureStorage secure;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    secure = _FakeSecureStorage();
    storage = AuthStorage(secureStorage: secure);
  });

  // ---------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------
  group('Token', () {
    test('getToken returns null before any save', () async {
      expect(await storage.getToken(), isNull);
    });

    test('saveToken then getToken returns the token', () async {
      await storage.saveToken('abc123');
      expect(await storage.getToken(), 'abc123');
    });

    test('overwriting token returns the latest value', () async {
      await storage.saveToken('first');
      await storage.saveToken('second');
      expect(await storage.getToken(), 'second');
    });
  });

  // ---------------------------------------------------------------
  // User
  // ---------------------------------------------------------------
  group('User', () {
    const testUser = User(
      pk: 1,
      username: 'jdoe',
      email: 'jdoe@test.com',
      firstName: 'John',
      lastName: 'Doe',
      location: 'London',
      isCoach: true,
      isOrganiser: false,
      verified: true,
    );

    test('getUser returns null before any save', () async {
      expect(await storage.getUser(), isNull);
    });

    test('saveUser then getUser returns the user', () async {
      await storage.saveUser(testUser);
      final restored = await storage.getUser();
      expect(restored, isNotNull);
      expect(restored!.pk, testUser.pk);
      expect(restored.username, testUser.username);
      expect(restored.email, testUser.email);
      expect(restored.firstName, testUser.firstName);
      expect(restored.isCoach, testUser.isCoach);
    });

    test('overwriting user returns the latest value', () async {
      await storage.saveUser(testUser);
      const updated = User(
        pk: 2,
        username: 'updated',
        email: '',
        firstName: '',
        lastName: '',
        location: '',
        isCoach: false,
        isOrganiser: true,
        verified: false,
      );
      await storage.saveUser(updated);
      final restored = await storage.getUser();
      expect(restored!.pk, 2);
      expect(restored.username, 'updated');
    });
  });

  // ---------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------
  group('Clear', () {
    test('clear removes token and user', () async {
      await storage.saveToken('token');
      await storage.saveUser(const User(
        pk: 1,
        username: 'u',
        email: '',
        firstName: '',
        lastName: '',
        location: '',
        isCoach: false,
        isOrganiser: false,
        verified: false,
      ));

      await storage.clear();

      expect(await storage.getToken(), isNull);
      expect(await storage.getUser(), isNull);
    });
  });
}
