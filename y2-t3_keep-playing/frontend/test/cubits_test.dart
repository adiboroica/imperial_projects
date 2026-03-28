import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:keep_playing_frontend/api/client.dart';
import 'package:keep_playing_frontend/api/coach.dart';
import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/api/users.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/pages/coach/feed/feed_cubit.dart';
import 'package:keep_playing_frontend/pages/coach/upcoming_jobs/upcoming_jobs_cubit.dart';
import 'package:keep_playing_frontend/pages/organiser/events/events_cubit.dart';
import 'package:keep_playing_frontend/pages/organiser/profile/organiser_cubit.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/state/auth_state.dart';
import 'package:keep_playing_frontend/state/auth_storage.dart';
import 'package:keep_playing_frontend/state/data_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockApiClient extends Mock implements ApiClient {}

class MockApiCoach extends Mock implements ApiCoach {}

class MockApiOrganiser extends Mock implements ApiOrganiser {}

class MockApiUsers extends Mock implements ApiUsers {}

class MockAuthStorage extends Mock implements AuthStorage {}

// ---------------------------------------------------------------------------
// Helper – build Event instances with sensible defaults
// ---------------------------------------------------------------------------

Event makeEvent({
  int pk = 1,
  String name = 'Test Event',
  String location = 'London',
  String details = 'Some details',
  String sport = 'Football',
  String role = 'Coach',
  DateTime? date,
  DateTime? creationStarted,
  DateTime? creationEnded,
  TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0),
  TimeOfDay endTime = const TimeOfDay(hour: 12, minute: 0),
  TimeOfDay flexibleStartTime = const TimeOfDay(hour: 9, minute: 0),
  TimeOfDay flexibleEndTime = const TimeOfDay(hour: 13, minute: 0),
  int price = 50,
  bool coach = false,
  bool recurring = false,
  int? coachPk,
  List<int> offers = const [],
  bool rated = false,
}) {
  final now = DateTime.now();
  final eventDate = date ?? now.add(const Duration(days: 7));
  return Event(
    pk: pk,
    name: name,
    location: location,
    details: details,
    sport: sport,
    role: role,
    date: eventDate,
    creationStarted: creationStarted ?? now,
    creationEnded: creationEnded ?? now,
    startTime: startTime,
    endTime: endTime,
    flexibleStartTime: flexibleStartTime,
    flexibleEndTime: flexibleEndTime,
    price: price,
    coach: coach,
    recurring: recurring,
    coachPk: coachPk,
    offers: offers,
    rated: rated,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockApiCoach mockApiCoach;
  late MockApiOrganiser mockApiOrganiser;

  setUp(() {
    mockApiCoach = MockApiCoach();
    mockApiOrganiser = MockApiOrganiser();
  });

  // -----------------------------------------------------------------------
  // 1. FeedCubit
  // -----------------------------------------------------------------------
  group('FeedCubit', () {
    test('initial state is DataInitial', () {
      when(() => mockApiCoach.getFeedEvents())
          .thenAnswer((_) async => <Event>[]);
      final cubit = FeedCubit(apiCoach: mockApiCoach);
      expect(cubit.state, isA<DataInitial<List<Event>>>());
      cubit.close();
    });

    blocTest<FeedCubit, DataState<List<Event>>>(
      'loadFeed emits [DataLoading, DataLoaded] on success',
      build: () {
        when(() => mockApiCoach.getFeedEvents())
            .thenAnswer((_) async => [makeEvent(pk: 1)]);
        return FeedCubit(apiCoach: mockApiCoach);
      },
      act: (cubit) => cubit.loadFeed(),
      expect: () => [
        isA<DataLoading<List<Event>>>(),
        isA<DataLoaded<List<Event>>>()
            .having((s) => s.data.length, 'event count', 1),
      ],
    );

    blocTest<FeedCubit, DataState<List<Event>>>(
      'loadFeed emits [DataLoading, DataError] on failure',
      build: () {
        when(() => mockApiCoach.getFeedEvents())
            .thenThrow(Exception('network error'));
        return FeedCubit(apiCoach: mockApiCoach);
      },
      act: (cubit) => cubit.loadFeed(),
      expect: () => [
        isA<DataLoading<List<Event>>>(),
        isA<DataError<List<Event>>>()
            .having((s) => s.message, 'message', contains('network error')),
      ],
    );
  });

  // -----------------------------------------------------------------------
  // 2. UpcomingJobsCubit
  // -----------------------------------------------------------------------
  group('UpcomingJobsCubit', () {
    test('initial state is DataInitial', () {
      when(() => mockApiCoach.getUpcomingJobs())
          .thenAnswer((_) async => <Event>[]);
      final cubit = UpcomingJobsCubit(apiCoach: mockApiCoach);
      expect(cubit.state, isA<DataInitial<List<Event>>>());
      cubit.close();
    });

    blocTest<UpcomingJobsCubit, DataState<List<Event>>>(
      'loadUpcomingJobs emits [DataLoading, DataLoaded] on success',
      build: () {
        when(() => mockApiCoach.getUpcomingJobs())
            .thenAnswer((_) async => [makeEvent(pk: 10), makeEvent(pk: 11)]);
        return UpcomingJobsCubit(apiCoach: mockApiCoach);
      },
      act: (cubit) => cubit.loadUpcomingJobs(),
      expect: () => [
        isA<DataLoading<List<Event>>>(),
        isA<DataLoaded<List<Event>>>()
            .having((s) => s.data.length, 'event count', 2),
      ],
    );

    blocTest<UpcomingJobsCubit, DataState<List<Event>>>(
      'loadUpcomingJobs emits [DataLoading, DataError] on failure',
      build: () {
        when(() => mockApiCoach.getUpcomingJobs())
            .thenThrow(Exception('server error'));
        return UpcomingJobsCubit(apiCoach: mockApiCoach);
      },
      act: (cubit) => cubit.loadUpcomingJobs(),
      expect: () => [
        isA<DataLoading<List<Event>>>(),
        isA<DataError<List<Event>>>()
            .having((s) => s.message, 'message', contains('server error')),
      ],
    );
  });

  // -----------------------------------------------------------------------
  // 3. EventsCubit – load + filter logic
  // -----------------------------------------------------------------------
  group('EventsCubit', () {
    // Shared test events – dates far enough in the past / future to be
    // deterministic regardless of the exact second the test runs.
    late Event pastUnassigned; // past, no coach
    late Event pastAssigned; // past, has coach
    late Event futureUnassigned; // future, no coach  (pending)
    late Event futureAssigned; // future, has coach  (scheduled)

    setUp(() {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final nextWeek = DateTime.now().add(const Duration(days: 7));

      pastUnassigned = makeEvent(
        pk: 1,
        name: 'Past Unassigned',
        date: yesterday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        coach: false,
      );
      pastAssigned = makeEvent(
        pk: 2,
        name: 'Past Assigned',
        date: yesterday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        coach: true,
        coachPk: 100,
      );
      futureUnassigned = makeEvent(
        pk: 3,
        name: 'Future Unassigned',
        date: nextWeek,
        startTime: const TimeOfDay(hour: 14, minute: 0),
        coach: false,
      );
      futureAssigned = makeEvent(
        pk: 4,
        name: 'Future Assigned',
        date: nextWeek,
        startTime: const TimeOfDay(hour: 14, minute: 0),
        coach: true,
        coachPk: 200,
      );
    });

    List<Event> allFourEvents() =>
        [pastUnassigned, pastAssigned, futureUnassigned, futureAssigned];

    blocTest<EventsCubit, DataState<List<Event>>>(
      'loadEvents emits [DataLoading, DataLoaded] on success',
      build: () {
        when(() => mockApiOrganiser.getEvents())
            .thenAnswer((_) async => allFourEvents());
        return EventsCubit(apiOrganiser: mockApiOrganiser);
      },
      act: (cubit) => cubit.loadEvents(),
      expect: () => [
        isA<DataLoading<List<Event>>>(),
        isA<DataLoaded<List<Event>>>()
            .having((s) => s.data.length, 'event count', 4),
      ],
    );

    blocTest<EventsCubit, DataState<List<Event>>>(
      'loadEvents emits [DataLoading, DataError] on failure',
      build: () {
        when(() => mockApiOrganiser.getEvents())
            .thenThrow(Exception('api failure'));
        return EventsCubit(apiOrganiser: mockApiOrganiser);
      },
      act: (cubit) => cubit.loadEvents(),
      expect: () => [
        isA<DataLoading<List<Event>>>(),
        isA<DataError<List<Event>>>()
            .having((s) => s.message, 'message', contains('api failure')),
      ],
    );

    // --- Filter tests (multi-step, plain test()) --------------------------

    test('setAllowPastEvents(false) filters out past events', () async {
      when(() => mockApiOrganiser.getEvents())
          .thenAnswer((_) async => allFourEvents());
      final cubit = EventsCubit(apiOrganiser: mockApiOrganiser);
      await cubit.loadEvents();

      cubit.setAllowPastEvents(false);
      final state = cubit.state;
      expect(state, isA<DataLoaded<List<Event>>>());
      final events = (state as DataLoaded<List<Event>>).data;

      // Only future events should remain.
      expect(events.length, 2);
      expect(events.any((e) => e.pk == pastUnassigned.pk), isFalse);
      expect(events.any((e) => e.pk == pastAssigned.pk), isFalse);
      expect(events.any((e) => e.pk == futureUnassigned.pk), isTrue);
      expect(events.any((e) => e.pk == futureAssigned.pk), isTrue);

      cubit.close();
    });

    test('setAllowPendingEvents(false) filters out events without a coach',
        () async {
      when(() => mockApiOrganiser.getEvents())
          .thenAnswer((_) async => allFourEvents());
      final cubit = EventsCubit(apiOrganiser: mockApiOrganiser);
      await cubit.loadEvents();

      cubit.setAllowPendingEvents(false);
      final state = cubit.state;
      expect(state, isA<DataLoaded<List<Event>>>());
      final events = (state as DataLoaded<List<Event>>).data;

      // Only events WITH a coach should remain.
      expect(events.length, 2);
      expect(events.any((e) => e.pk == pastUnassigned.pk), isFalse);
      expect(events.any((e) => e.pk == futureUnassigned.pk), isFalse);
      expect(events.any((e) => e.pk == pastAssigned.pk), isTrue);
      expect(events.any((e) => e.pk == futureAssigned.pk), isTrue);

      cubit.close();
    });

    test(
        'setAllowScheduledEvents(false) filters out events with a coach '
        'that are in the future', () async {
      when(() => mockApiOrganiser.getEvents())
          .thenAnswer((_) async => allFourEvents());
      final cubit = EventsCubit(apiOrganiser: mockApiOrganiser);
      await cubit.loadEvents();

      cubit.setAllowScheduledEvents(false);
      final state = cubit.state;
      expect(state, isA<DataLoaded<List<Event>>>());
      final events = (state as DataLoaded<List<Event>>).data;

      // "Scheduled" = hasCoach && isInTheFuture. Only futureAssigned
      // matches, so everything EXCEPT futureAssigned should remain.
      expect(events.length, 3);
      expect(events.any((e) => e.pk == futureAssigned.pk), isFalse);
      expect(events.any((e) => e.pk == pastUnassigned.pk), isTrue);
      expect(events.any((e) => e.pk == pastAssigned.pk), isTrue);
      expect(events.any((e) => e.pk == futureUnassigned.pk), isTrue);

      cubit.close();
    });

    test('filters combine correctly', () async {
      when(() => mockApiOrganiser.getEvents())
          .thenAnswer((_) async => allFourEvents());
      final cubit = EventsCubit(apiOrganiser: mockApiOrganiser);
      await cubit.loadEvents();

      // Disallow past AND disallow pending (no coach).
      // remaining: only futureAssigned (future + has coach)
      //            and futureUnassigned is excluded because it has no coach.
      //            Wait – disallow pending removes no-coach events,
      //            disallow past removes past events.
      //   pastUnassigned  -> removed (past)
      //   pastAssigned    -> removed (past)
      //   futureUnassigned -> removed (no coach = pending)
      //   futureAssigned  -> KEPT (future + has coach)
      cubit.setAllowPastEvents(false);
      cubit.setAllowPendingEvents(false);

      final state = cubit.state;
      expect(state, isA<DataLoaded<List<Event>>>());
      final events = (state as DataLoaded<List<Event>>).data;

      expect(events.length, 1);
      expect(events.first.pk, futureAssigned.pk);

      cubit.close();
    });

    test('all filters disabled at once keeps only matching events', () async {
      when(() => mockApiOrganiser.getEvents())
          .thenAnswer((_) async => allFourEvents());
      final cubit = EventsCubit(apiOrganiser: mockApiOrganiser);
      await cubit.loadEvents();

      // Disallow past, pending, AND scheduled.
      //   pastUnassigned   -> removed (past)
      //   pastAssigned     -> removed (past)
      //   futureUnassigned -> removed (pending – no coach)
      //   futureAssigned   -> removed (scheduled – has coach + future)
      cubit.setAllowPastEvents(false);
      cubit.setAllowPendingEvents(false);
      cubit.setAllowScheduledEvents(false);

      final state = cubit.state;
      expect(state, isA<DataLoaded<List<Event>>>());
      final events = (state as DataLoaded<List<Event>>).data;

      expect(events, isEmpty);

      cubit.close();
    });

    test('re-enabling a filter restores previously hidden events', () async {
      when(() => mockApiOrganiser.getEvents())
          .thenAnswer((_) async => allFourEvents());
      final cubit = EventsCubit(apiOrganiser: mockApiOrganiser);
      await cubit.loadEvents();

      cubit.setAllowPastEvents(false);
      expect(
        (cubit.state as DataLoaded<List<Event>>).data.length,
        2,
      );

      // Re-enable past events – all four should come back.
      cubit.setAllowPastEvents(true);
      expect(
        (cubit.state as DataLoaded<List<Event>>).data.length,
        4,
      );

      cubit.close();
    });
  });

  // -----------------------------------------------------------------------
  // 4. AuthCubit
  // -----------------------------------------------------------------------
  group('AuthCubit', () {
    late MockApiClient mockApiClient;
    late MockApiUsers mockApiUsers;
    late MockAuthStorage mockStorage;

    const testUser = User(
      pk: 1,
      username: 'testuser',
      email: 'test@test.com',
      firstName: 'Test',
      lastName: 'User',
      location: 'London',
      isCoach: true,
      isOrganiser: false,
      verified: true,
    );

    const testLogin = UserLogin(username: 'testuser', password: 'pass');

    setUpAll(() {
      registerFallbackValue(const User(
        pk: 0, username: '', email: '', firstName: '', lastName: '',
        location: '', isCoach: false, isOrganiser: false, verified: false,
      ));
      registerFallbackValue(const UserLogin(username: '', password: ''));
    });

    setUp(() {
      mockApiClient = MockApiClient();
      mockApiUsers = MockApiUsers();
      mockStorage = MockAuthStorage();
      // Stub restoreSession dependencies (called in constructor)
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);
      when(() => mockStorage.getUser()).thenAnswer((_) async => null);
    });

    test('initial state is AuthInitial', () {
      final cubit = AuthCubit(
        apiClient: mockApiClient,
        apiUsers: mockApiUsers,
        storage: mockStorage,
      );
      expect(cubit.state, isA<AuthInitial>());
      cubit.close();
    });

    test('currentUser returns null when not authenticated', () {
      final cubit = AuthCubit(
        apiClient: mockApiClient,
        apiUsers: mockApiUsers,
        storage: mockStorage,
      );
      expect(cubit.currentUser, isNull);
      cubit.close();
    });

    /// Helper: create cubit and wait for restoreSession to complete.
    Future<AuthCubit> createCubit() async {
      final cubit = AuthCubit(
        apiClient: mockApiClient,
        apiUsers: mockApiUsers,
        storage: mockStorage,
      );
      // Let the constructor's restoreSession() future resolve.
      await Future<void>.delayed(Duration.zero);
      return cubit;
    }

    test('login success emits AuthAuthenticated and sets currentUser', () async {
      when(() => mockApiUsers.login(userLogin: testLogin)).thenAnswer(
        (_) async => http.Response('{"token":"abc123"}', 200),
      );
      when(() => mockApiUsers.getCurrentUser()).thenAnswer(
        (_) async => testUser,
      );
      when(() => mockApiClient.setToken(any())).thenReturn(null);
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveUser(any())).thenAnswer((_) async {});

      final cubit = await createCubit();

      await cubit.login(userLogin: testLogin);

      expect(cubit.state, isA<AuthAuthenticated>());
      final authenticated = cubit.state as AuthAuthenticated;
      expect(authenticated.user.username, 'testuser');
      expect(authenticated.token, 'abc123');

      // Verify currentUser getter works after login
      expect(cubit.currentUser, isNotNull);
      expect(cubit.currentUser!.username, 'testuser');

      verify(() => mockApiClient.setToken('abc123')).called(1);
      verify(() => mockStorage.saveToken('abc123')).called(1);
      verify(() => mockStorage.saveUser(any())).called(1);

      cubit.close();
    });

    test('login succeeds with token but getCurrentUser fails emits AuthError',
        () async {
      when(() => mockApiUsers.login(userLogin: testLogin)).thenAnswer(
        (_) async => http.Response('{"token":"abc123"}', 200),
      );
      when(() => mockApiUsers.getCurrentUser())
          .thenThrow(Exception('profile fetch failed'));
      when(() => mockApiClient.setToken(any())).thenReturn(null);
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});

      final cubit = await createCubit();

      await cubit.login(userLogin: testLogin);

      // Token was obtained but user profile fetch failed — should error
      expect(cubit.state, isA<AuthError>());
      expect(
        (cubit.state as AuthError).message,
        contains('profile fetch failed'),
      );

      cubit.close();
    });

    test('login with bad credentials emits AuthError', () async {
      when(() => mockApiUsers.login(userLogin: testLogin)).thenAnswer(
        (_) async => http.Response('{"error":"bad"}', 400),
      );

      final cubit = await createCubit();

      await cubit.login(userLogin: testLogin);

      expect(cubit.state, isA<AuthError>());
      expect((cubit.state as AuthError).message, 'Invalid credentials');

      cubit.close();
    });

    test('login with network error emits AuthError', () async {
      when(() => mockApiUsers.login(userLogin: testLogin))
          .thenThrow(Exception('network failed'));

      final cubit = await createCubit();

      await cubit.login(userLogin: testLogin);

      expect(cubit.state, isA<AuthError>());
      expect((cubit.state as AuthError).message, contains('network failed'));

      cubit.close();
    });

    test('logout clears token/storage and emits AuthUnauthenticated', () async {
      when(() => mockApiClient.setToken(any())).thenReturn(null);
      when(() => mockStorage.clear()).thenAnswer((_) async {});

      final cubit = await createCubit();

      await cubit.logout();

      expect(cubit.state, isA<AuthUnauthenticated>());
      verify(() => mockApiClient.setToken(null)).called(1);
      verify(() => mockStorage.clear()).called(1);

      cubit.close();
    });

    test('restoreSession restores authenticated state from storage', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => 'saved_token');
      when(() => mockStorage.getUser()).thenAnswer((_) async => testUser);
      when(() => mockApiClient.setToken(any())).thenReturn(null);

      final cubit = AuthCubit(
        apiClient: mockApiClient,
        apiUsers: mockApiUsers,
        storage: mockStorage,
      );
      // Wait for restoreSession
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthAuthenticated>());
      final auth = cubit.state as AuthAuthenticated;
      expect(auth.token, 'saved_token');
      expect(auth.user.username, 'testuser');
      verify(() => mockApiClient.setToken('saved_token')).called(1);

      cubit.close();
    });
  });

  // -----------------------------------------------------------------------
  // 5. OrganiserCubit
  // -----------------------------------------------------------------------
  group('OrganiserCubit', () {
    late MockApiOrganiser mockApiOrganiser;

    const initialOrganiser = Organiser(
      favourites: [1, 2],
      blocked: [3],
      defaultSport: 'Football',
      defaultRole: 'Coach',
      defaultLocation: 'London',
      defaultPrice: 50,
    );

    const reloadedOrganiser = Organiser(
      favourites: [1, 2, 4],
      blocked: [],
      defaultSport: 'Tennis',
      defaultRole: 'Referee',
      defaultLocation: 'Manchester',
      defaultPrice: 75,
    );

    setUp(() {
      mockApiOrganiser = MockApiOrganiser();
    });

    test('initial state is the provided organiser', () {
      final cubit = OrganiserCubit(
        apiOrganiser: mockApiOrganiser,
        initialOrganiser: initialOrganiser,
      );
      expect(cubit.state.defaultSport, 'Football');
      expect(cubit.state.favourites, [1, 2]);
      cubit.close();
    });

    test('reload emits new organiser on success', () async {
      when(() => mockApiOrganiser.getOrganiser())
          .thenAnswer((_) async => reloadedOrganiser);

      final cubit = OrganiserCubit(
        apiOrganiser: mockApiOrganiser,
        initialOrganiser: initialOrganiser,
      );

      await cubit.reload();

      expect(cubit.state.defaultSport, 'Tennis');
      expect(cubit.state.favourites, [1, 2, 4]);
      expect(cubit.state.blocked, isEmpty);

      cubit.close();
    });

    test('reload keeps current state on failure', () async {
      when(() => mockApiOrganiser.getOrganiser())
          .thenThrow(Exception('network error'));

      final cubit = OrganiserCubit(
        apiOrganiser: mockApiOrganiser,
        initialOrganiser: initialOrganiser,
      );

      await cubit.reload();

      // State should remain unchanged
      expect(cubit.state.defaultSport, 'Football');
      expect(cubit.state.favourites, [1, 2]);

      cubit.close();
    });
  });
}
