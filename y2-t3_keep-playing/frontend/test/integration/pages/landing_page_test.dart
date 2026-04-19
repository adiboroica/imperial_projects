import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/pages/landing_page.dart';
import 'package:keep_playing_frontend/repositories/auth_repository.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/state/auth_storage.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthStorage extends Mock implements AuthStorage {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(const UserLogin(username: '', password: ''));
    registerFallbackValue(const User(
      pk: 0,
      username: '',
      email: '',
      firstName: '',
      lastName: '',
      location: '',
      isCoach: false,
      isOrganiser: false,
      verified: false,
    ));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthRepository = MockAuthRepository();
    mockStorage = MockAuthStorage();
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockStorage.getUser()).thenAnswer((_) async => null);
  });

  Widget buildApp({AuthCubit? cubit}) {
    final authCubit = cubit ??
        AuthCubit(
          authRepository: mockAuthRepository,
          storage: mockStorage,
        );
    return BlocProvider.value(
      value: authCubit,
      child: const MaterialApp(
        home: LandingPage(),
      ),
    );
  }

  group('Landing page', () {
    testWidgets('shows organiser and coach buttons', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Enter as organiser'), findsOneWidget);
      expect(find.text('Enter as coach'), findsOneWidget);
    });

    testWidgets('tapping organiser button navigates to login', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enter as organiser'));
      await tester.pumpAndSettle();

      // Should navigate away from landing page
      expect(find.text('Enter as organiser'), findsNothing);
    });

    testWidgets('tapping coach button navigates to login', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enter as coach'));
      await tester.pumpAndSettle();

      expect(find.text('Enter as coach'), findsNothing);
    });
  });
}
