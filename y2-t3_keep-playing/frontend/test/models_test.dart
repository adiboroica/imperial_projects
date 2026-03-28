import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keep_playing_frontend/models/coach_rating.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/utils.dart';

void main() {
  // ---------------------------------------------------------------
  // 1. User tests
  // ---------------------------------------------------------------
  group('User', () {
    test('fromJson creates User with all fields', () {
      final json = {
        'pk': 1,
        'username': 'jdoe',
        'email': 'jdoe@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'location': 'London',
        'is_coach': true,
        'is_organiser': false,
        'verified': true,
      };

      final user = User.fromJson(json);

      expect(user.pk, 1);
      expect(user.username, 'jdoe');
      expect(user.email, 'jdoe@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.location, 'London');
      expect(user.isCoach, true);
      expect(user.isOrganiser, false);
      expect(user.verified, true);
    });

    test('fromJson handles null/missing optional fields with defaults', () {
      final json = {
        'pk': 2,
        'username': 'minimal',
      };

      final user = User.fromJson(json);

      expect(user.pk, 2);
      expect(user.username, 'minimal');
      expect(user.email, '');
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.location, '');
      expect(user.isCoach, false);
      expect(user.isOrganiser, false);
      expect(user.verified, false);
    });

    test('toJson round-trip produces equivalent data', () {
      const original = User(
        pk: 5,
        username: 'roundtrip',
        email: 'rt@example.com',
        firstName: 'Round',
        lastName: 'Trip',
        location: 'Manchester',
        isCoach: true,
        isOrganiser: true,
        verified: true,
      );

      final json = original.toJson();
      final restored = User.fromJson(json);

      expect(restored.pk, original.pk);
      expect(restored.username, original.username);
      expect(restored.email, original.email);
      expect(restored.firstName, original.firstName);
      expect(restored.lastName, original.lastName);
      expect(restored.location, original.location);
      expect(restored.isCoach, original.isCoach);
      expect(restored.isOrganiser, original.isOrganiser);
      expect(restored.verified, original.verified);
    });

    test('fullName returns concatenated first/last name', () {
      const user = User(
        pk: 3,
        username: 'jsmith',
        email: 'js@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        location: 'Bristol',
        isCoach: false,
        isOrganiser: true,
        verified: false,
      );

      expect(user.fullName, 'Jane Smith');
    });
  });

  // ---------------------------------------------------------------
  // 2. Event tests
  // ---------------------------------------------------------------
  group('Event', () {
    test('fromJson creates Event with all fields including date/time parsing',
        () {
      final json = {
        'pk': 10,
        'name': 'Football Training',
        'location': 'Hyde Park',
        'details': 'Bring boots',
        'sport': 'Football',
        'role': 'Striker Coach',
        'date': '2030-06-15',
        'creation_started': '2030-06-01',
        'creation_ended': '2030-06-10',
        'start_time': '09:30',
        'end_time': '11:00',
        'flexible_start_time': '09:00',
        'flexible_end_time': '11:30',
        'price': 25,
        'coach': true,
        'recurring': false,
        'coach_user': 42,
        'offers': [1, 2, 3],
        'voted': true,
      };

      final event = Event.fromJson(json);

      expect(event.pk, 10);
      expect(event.name, 'Football Training');
      expect(event.location, 'Hyde Park');
      expect(event.details, 'Bring boots');
      expect(event.sport, 'Football');
      expect(event.role, 'Striker Coach');
      expect(event.date, DateTime(2030, 6, 15));
      expect(event.creationStarted, DateTime(2030, 6, 1));
      expect(event.creationEnded, DateTime(2030, 6, 10));
      expect(event.startTime, const TimeOfDay(hour: 9, minute: 30));
      expect(event.endTime, const TimeOfDay(hour: 11, minute: 0));
      expect(event.flexibleStartTime, const TimeOfDay(hour: 9, minute: 0));
      expect(event.flexibleEndTime, const TimeOfDay(hour: 11, minute: 30));
      expect(event.price, 25);
      expect(event.coach, true);
      expect(event.recurring, false);
      expect(event.coachPk, 42);
      expect(event.offers, [1, 2, 3]);
      expect(event.rated, true);
    });

    test('fromJson handles null/missing optional fields', () {
      final json = {
        'pk': 11,
        'name': 'Minimal Event',
        'date': '2030-07-01',
        'start_time': '10:00',
        'end_time': '12:00',
        'flexible_start_time': '09:00',
        'flexible_end_time': '13:00',
        'price': 0,
        'coach': false,
        'offers': <dynamic>[],
      };

      final event = Event.fromJson(json);

      expect(event.location, '');
      expect(event.details, '');
      expect(event.sport, '');
      expect(event.role, '');
      expect(event.recurring, false);
      expect(event.coachPk, isNull);
      expect(event.rated, false);
      // creation_started / creation_ended default to date when missing
      expect(event.creationStarted, DateTime(2030, 7, 1));
      expect(event.creationEnded, DateTime(2030, 7, 1));
    });

    group('check() filter logic', () {
      // Helper to create a future event (next year)
      final futureDate = DateTime.now().add(const Duration(days: 365));
      final pastDate = DateTime.now().subtract(const Duration(days: 365));

      Event makeEvent({
        required DateTime date,
        bool coach = false,
        int? coachPk,
      }) {
        return Event(
          pk: 1,
          name: 'Test',
          location: 'Loc',
          details: '',
          sport: 'Football',
          role: 'Coach',
          date: date,
          creationStarted: date,
          creationEnded: date,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 12, minute: 0),
          flexibleStartTime: const TimeOfDay(hour: 9, minute: 0),
          flexibleEndTime: const TimeOfDay(hour: 13, minute: 0),
          price: 10,
          coach: coach,
          recurring: false,
          coachPk: coachPk,
          offers: const [],
          rated: false,
        );
      }

      test('returns true when all filters allow', () {
        final event = makeEvent(date: futureDate, coach: true);

        expect(
          event.check(
            allowPastEvents: true,
            allowPendingEvents: true,
            allowScheduledEvents: true,
          ),
          isTrue,
        );
      });

      test('filters out past events when allowPastEvents is false', () {
        final past = makeEvent(date: pastDate);
        final future = makeEvent(date: futureDate);

        expect(
          past.check(
            allowPastEvents: false,
            allowPendingEvents: true,
            allowScheduledEvents: true,
          ),
          isFalse,
        );
        expect(
          future.check(
            allowPastEvents: false,
            allowPendingEvents: true,
            allowScheduledEvents: true,
          ),
          isTrue,
        );
      });

      test('filters out pending events when allowPendingEvents is false', () {
        final pendingEvent = makeEvent(date: futureDate, coach: false);
        final confirmedEvent = makeEvent(date: futureDate, coach: true);

        expect(
          pendingEvent.check(
            allowPastEvents: true,
            allowPendingEvents: false,
            allowScheduledEvents: true,
          ),
          isFalse,
        );
        expect(
          confirmedEvent.check(
            allowPastEvents: true,
            allowPendingEvents: false,
            allowScheduledEvents: true,
          ),
          isTrue,
        );
      });

      test('filters out scheduled events when allowScheduledEvents is false',
          () {
        // Scheduled = has coach AND is in the future
        final scheduled =
            makeEvent(date: futureDate, coach: true);
        final pendingFuture =
            makeEvent(date: futureDate, coach: false);

        expect(
          scheduled.check(
            allowPastEvents: true,
            allowPendingEvents: true,
            allowScheduledEvents: false,
          ),
          isFalse,
        );
        // A future event without a coach is not "scheduled", so it passes
        expect(
          pendingFuture.check(
            allowPastEvents: true,
            allowPendingEvents: true,
            allowScheduledEvents: false,
          ),
          isTrue,
        );
      });

      test('filters by day with onDay parameter', () {
        final event = makeEvent(date: futureDate);

        expect(
          event.check(
            allowPastEvents: true,
            allowPendingEvents: true,
            allowScheduledEvents: true,
            onDay: futureDate,
          ),
          isTrue,
        );
        expect(
          event.check(
            allowPastEvents: true,
            allowPendingEvents: true,
            allowScheduledEvents: true,
            onDay: futureDate.add(const Duration(days: 1)),
          ),
          isFalse,
        );
      });

      test('filters by coach with withCoachUser parameter', () {
        final event = makeEvent(date: futureDate, coach: true, coachPk: 99);
        const matchingCoach = User(
          pk: 99,
          username: 'coach99',
          email: '',
          firstName: '',
          lastName: '',
          location: '',
          isCoach: true,
          isOrganiser: false,
          verified: true,
        );
        const otherCoach = User(
          pk: 100,
          username: 'coach100',
          email: '',
          firstName: '',
          lastName: '',
          location: '',
          isCoach: true,
          isOrganiser: false,
          verified: true,
        );

        expect(
          event.check(
            allowPastEvents: true,
            allowPendingEvents: true,
            allowScheduledEvents: true,
            withCoachUser: matchingCoach,
          ),
          isTrue,
        );
        expect(
          event.check(
            allowPastEvents: true,
            allowPendingEvents: true,
            allowScheduledEvents: true,
            withCoachUser: otherCoach,
          ),
          isFalse,
        );
      });
    });

    test('priceInPounds returns formatted currency', () {
      final json = {
        'pk': 20,
        'name': 'Priced Event',
        'date': '2030-01-01',
        'start_time': '10:00',
        'end_time': '12:00',
        'flexible_start_time': '09:00',
        'flexible_end_time': '13:00',
        'price': 50,
        'coach': false,
        'offers': <dynamic>[],
      };

      final event = Event.fromJson(json);

      // NumberFormat.simpleCurrency(name: 'GBP') uses £ symbol
      expect(event.priceInPounds, contains('50'));
      expect(event.priceInPounds, contains('£'));
    });

    test('isInThePast and isInTheFuture work correctly', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 365));
      final futureDate = DateTime.now().add(const Duration(days: 365));

      final pastEvent = Event(
        pk: 1,
        name: 'Past',
        location: '',
        details: '',
        sport: '',
        role: '',
        date: pastDate,
        creationStarted: pastDate,
        creationEnded: pastDate,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        flexibleStartTime: const TimeOfDay(hour: 9, minute: 0),
        flexibleEndTime: const TimeOfDay(hour: 13, minute: 0),
        price: 10,
        coach: false,
        recurring: false,
        offers: const [],
        rated: false,
      );

      final futureEvent = Event(
        pk: 2,
        name: 'Future',
        location: '',
        details: '',
        sport: '',
        role: '',
        date: futureDate,
        creationStarted: futureDate,
        creationEnded: futureDate,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        flexibleStartTime: const TimeOfDay(hour: 9, minute: 0),
        flexibleEndTime: const TimeOfDay(hour: 13, minute: 0),
        price: 10,
        coach: false,
        recurring: false,
        offers: const [],
        rated: false,
      );

      expect(pastEvent.isInThePast, isTrue);
      expect(pastEvent.isInTheFuture, isFalse);
      expect(futureEvent.isInThePast, isFalse);
      expect(futureEvent.isInTheFuture, isTrue);
    });
  });

  // ---------------------------------------------------------------
  // 3. NewEvent tests
  // ---------------------------------------------------------------
  group('NewEvent', () {
    test('toJson produces correct JSON map with proper date/time formatting',
        () {
      final newEvent = NewEvent(
        name: 'Tennis Lesson',
        location: 'Wimbledon',
        details: 'Bring racket',
        sport: 'Tennis',
        role: 'Tennis Coach',
        date: DateTime(2030, 8, 20),
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 30),
        flexibleStartTime: const TimeOfDay(hour: 13, minute: 0),
        flexibleEndTime: const TimeOfDay(hour: 17, minute: 0),
        price: 40,
        coach: true,
        recurring: false,
        creationStarted: DateTime(2030, 8, 1, 9, 15, 30),
        creationEnded: DateTime(2030, 8, 10, 17, 45, 0),
      );

      final json = newEvent.toJson();

      expect(json['name'], 'Tennis Lesson');
      expect(json['location'], 'Wimbledon');
      expect(json['details'], 'Bring racket');
      expect(json['sport'], 'Tennis');
      expect(json['role'], 'Tennis Coach');
      expect(json['date'], '2030-08-20');
      expect(json['start_time'], '14:00');
      expect(json['end_time'], '16:30');
      expect(json['flexible_start_time'], '13:00');
      expect(json['flexible_end_time'], '17:00');
      expect(json['price'], '40');
      expect(json['coach'], 'True');
      expect(json['recurring'], 'False');
      expect(json['creation_started'], '2030-08-01 09:15:30');
      expect(json['creation_ended'], '2030-08-10 17:45:00');
    });

    test('fromEvent copies all fields from an Event', () {
      final event = Event(
        pk: 50,
        name: 'Swimming',
        location: 'Pool',
        details: 'Goggles required',
        sport: 'Swimming',
        role: 'Swim Coach',
        date: DateTime(2030, 9, 1),
        creationStarted: DateTime(2030, 8, 25),
        creationEnded: DateTime(2030, 8, 30),
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        flexibleStartTime: const TimeOfDay(hour: 7, minute: 30),
        flexibleEndTime: const TimeOfDay(hour: 10, minute: 30),
        price: 30,
        coach: true,
        recurring: true,
        coachPk: 7,
        offers: const [1, 2],
        rated: false,
      );

      final newEvent = NewEvent.fromEvent(event);

      expect(newEvent.name, event.name);
      expect(newEvent.location, event.location);
      expect(newEvent.details, event.details);
      expect(newEvent.sport, event.sport);
      expect(newEvent.role, event.role);
      expect(newEvent.date, event.date);
      expect(newEvent.startTime, event.startTime);
      expect(newEvent.endTime, event.endTime);
      expect(newEvent.flexibleStartTime, event.flexibleStartTime);
      expect(newEvent.flexibleEndTime, event.flexibleEndTime);
      expect(newEvent.price, event.price);
      expect(newEvent.coach, event.coach);
      expect(newEvent.recurring, event.recurring);
      expect(newEvent.creationStarted, event.creationStarted);
      expect(newEvent.creationEnded, event.creationEnded);
    });
  });

  // ---------------------------------------------------------------
  // 4. Organiser tests
  // ---------------------------------------------------------------
  group('Organiser', () {
    test('fromJson creates Organiser with all fields', () {
      final json = {
        'favourites': [1, 2, 3],
        'blocked': [4, 5],
        'default_sport': 'Rugby',
        'default_role': 'Scrum Coach',
        'default_location': 'Twickenham',
        'default_price': 60,
      };

      final organiser = Organiser.fromJson(json);

      expect(organiser.favourites, [1, 2, 3]);
      expect(organiser.blocked, [4, 5]);
      expect(organiser.defaultSport, 'Rugby');
      expect(organiser.defaultRole, 'Scrum Coach');
      expect(organiser.defaultLocation, 'Twickenham');
      expect(organiser.defaultPrice, 60);
    });

    test('isFavourite returns true/false correctly', () {
      const organiser = Organiser(
        favourites: [10, 20, 30],
        blocked: [],
        defaultSport: '',
        defaultRole: '',
        defaultLocation: '',
      );

      const favouriteUser = User(
        pk: 20,
        username: 'fav',
        email: '',
        firstName: '',
        lastName: '',
        location: '',
        isCoach: true,
        isOrganiser: false,
        verified: true,
      );
      const otherUser = User(
        pk: 99,
        username: 'other',
        email: '',
        firstName: '',
        lastName: '',
        location: '',
        isCoach: true,
        isOrganiser: false,
        verified: true,
      );

      expect(organiser.isFavourite(favouriteUser), isTrue);
      expect(organiser.isFavourite(otherUser), isFalse);
    });

    test('isBlocked returns true/false correctly', () {
      const organiser = Organiser(
        favourites: [],
        blocked: [5, 15],
        defaultSport: '',
        defaultRole: '',
        defaultLocation: '',
      );

      const blockedUser = User(
        pk: 15,
        username: 'blocked',
        email: '',
        firstName: '',
        lastName: '',
        location: '',
        isCoach: true,
        isOrganiser: false,
        verified: true,
      );
      const unblockedUser = User(
        pk: 77,
        username: 'free',
        email: '',
        firstName: '',
        lastName: '',
        location: '',
        isCoach: true,
        isOrganiser: false,
        verified: true,
      );

      expect(organiser.isBlocked(blockedUser), isTrue);
      expect(organiser.isBlocked(unblockedUser), isFalse);
    });
  });

  // ---------------------------------------------------------------
  // 5. CoachRating tests
  // ---------------------------------------------------------------
  group('CoachRating', () {
    test('fromJson creates CoachRating', () {
      final json = {
        'pk': 1,
        'votes': 10,
        'experience': 45,
        'flexibility': 38,
        'reliability': 50,
      };

      final rating = CoachRating.fromJson(json);

      expect(rating.pk, 1);
      expect(rating.votes, 10);
      expect(rating.experience, 45);
      expect(rating.flexibility, 38);
      expect(rating.reliability, 50);
    });

    test('average calculations are correct', () {
      const rating = CoachRating(
        pk: 2,
        votes: 4,
        experience: 20,
        flexibility: 16,
        reliability: 12,
      );

      expect(rating.experienceAverage, 5.0);
      expect(rating.flexibilityAverage, 4.0);
      expect(rating.reliabilityAverage, 3.0);
    });

    test('zero votes returns 0 for averages (no division by zero)', () {
      const rating = CoachRating(
        pk: 3,
        votes: 0,
        experience: 0,
        flexibility: 0,
        reliability: 0,
      );

      expect(rating.experienceAverage, 0);
      expect(rating.flexibilityAverage, 0);
      expect(rating.reliabilityAverage, 0);
    });
  });

  // ---------------------------------------------------------------
  // 6. formatTime tests
  // ---------------------------------------------------------------
  group('formatTime', () {
    test('formats single-digit hour and minute with leading zeros', () {
      expect(
        formatTime(const TimeOfDay(hour: 9, minute: 5)),
        '09:05',
      );
    });

    test('formats double-digit hour and minute correctly', () {
      expect(
        formatTime(const TimeOfDay(hour: 14, minute: 30)),
        '14:30',
      );
    });
  });
}
