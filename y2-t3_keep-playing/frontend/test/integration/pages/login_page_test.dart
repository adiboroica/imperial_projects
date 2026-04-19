import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/pages/shared_login_page.dart';
import 'package:keep_playing_frontend/repositories/auth_repository.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/state/auth_storage.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthStorage extends Mock implements AuthStorage {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthStorage mockStorage;

  const testUser = User(
    pk: 1,
    username: 'coach1',
    email: 'c@test.com',
    firstName: 'Test',
    lastName: 'Coach',
    location: 'London',
    isCoach: true,
    isOrganiser: false,
    verified: true,
  );

  setUpAll(() {
    registerFallbackValue(const UserLogin(username: '', password: ''));
    registerFallbackValue(testUser);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthRepository = MockAuthRepository();
    mockStorage = MockAuthStorage();
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockStorage.getUser()).thenAnswer((_) async => null);
  });

  Widget buildLoginPage() {
    final authCubit = AuthCubit(
      authRepository: mockAuthRepository,
      storage: mockStorage,
    );
    return MaterialApp(
      home: BlocProvider.value(
        value: authCubit,
        child: SharedLoginPage(
          title: 'Coach Login',
          roleCheck: (user) => user.isCoach,
          roleErrorMessage: 'Not a coach',
          buildSignUpPage: () => const Scaffold(body: Text('Sign Up')),
          buildHomePage: () => const Scaffold(body: Text('Home')),
        ),
      ),
    );
  }

  group('Login page', () {
    testWidgets('shows username and password fields', (tester) async {
      await tester.pumpWidget(buildLoginPage());
      await tester.pumpAndSettle();

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(buildLoginPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your username'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('successful login navigates to home', (tester) async {
      when(() => mockAuthRepository.login(userLogin: any(named: 'userLogin')))
          .thenAnswer((_) async => http.Response('{"token":"abc"}', 200));
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);
      when(() => mockAuthRepository.setToken(any())).thenReturn(null);
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveUser(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildLoginPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'coach1');
      await tester.enterText(find.byType(TextFormField).last, 'pass123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('failed login shows error snackbar', (tester) async {
      when(() => mockAuthRepository.login(userLogin: any(named: 'userLogin')))
          .thenAnswer((_) async => http.Response('{"error":"bad"}', 400));

      await tester.pumpWidget(buildLoginPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'wrong');
      await tester.enterText(find.byType(TextFormField).last, 'wrong');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('sign up link navigates to sign up page', (tester) async {
      await tester.pumpWidget(buildLoginPage());
      await tester.pumpAndSettle();

      // Use the specific TextButton copy rather than a loose containsText match
      // so we don't also hit the destination page's own "Sign Up" text.
      await tester.tap(
        find.widgetWithText(TextButton, "Don't have an account? Sign Up"),
      );
      await tester.pumpAndSettle();

      // The login page is gone; we landed on the stubbed sign-up scaffold.
      expect(find.text("Don't have an account? Sign Up"), findsNothing);
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });
}
