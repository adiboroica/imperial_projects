import 'package:flutter_test/flutter_test.dart';
import 'package:keep_playing_frontend/main.dart';

void main() {
  testWidgets('Landing Page shows two buttons ', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('Enter as organiser'), findsOneWidget);
    expect(find.text('Enter as coach'), findsOneWidget);
  });
}
