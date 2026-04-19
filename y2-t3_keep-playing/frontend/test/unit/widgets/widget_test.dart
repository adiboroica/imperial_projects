import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/error_display.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

void main() {
  // ---------------------------------------------------------------
  // ErrorDisplay
  // ---------------------------------------------------------------
  group('ErrorDisplay', () {
    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ErrorDisplay(message: 'Something went wrong'))),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ErrorDisplay(message: 'Error', onRetry: () {}))),
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ErrorDisplay(message: 'Error'))),
      );
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('tapping retry triggers callback', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ErrorDisplay(message: 'Error', onRetry: () => called = true))),
      );
      await tester.tap(find.text('Retry'));
      expect(called, isTrue);
    });
  });

  // ---------------------------------------------------------------
  // LoadingIndicator
  // ---------------------------------------------------------------
  group('LoadingIndicator', () {
    testWidgets('renders spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingScreen renders full-screen with spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoadingScreen()),
      );
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------
  // ConfirmationDialog
  // ---------------------------------------------------------------
  group('ConfirmationDialog', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConfirmationDialog(title: 'Are you sure?'))),
      );
      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('displays optional content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ConfirmationDialog(title: 'Delete?', content: 'This cannot be undone')),
        ),
      );
      expect(find.text('This cannot be undone'), findsOneWidget);
    });

    testWidgets('hides content when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConfirmationDialog(title: 'Delete?'))),
      );
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('Yes button pops with true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ConfirmationDialog(title: 'Confirm?'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('No button pops with false', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ConfirmationDialog(title: 'Confirm?'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });
}
