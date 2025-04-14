import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:blkwds_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Verify app launches and dashboard loads', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app title is displayed
      expect(find.text('BLKWDS Manager'), findsOneWidget);

      // Verify that the dashboard is loaded
      expect(find.text('Today\'s Bookings'), findsOneWidget);
      expect(find.text('Gear Status'), findsOneWidget);
    });

    testWidgets('Navigate to Booking Panel and back', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find and tap the Booking Panel button
      final bookingPanelButton = find.byIcon(Icons.calendar_today);
      await tester.tap(bookingPanelButton);
      await tester.pumpAndSettle();

      // Verify that we're on the Booking Panel screen
      expect(find.text('Booking Panel'), findsOneWidget);

      // Go back to the dashboard
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify that we're back on the dashboard
      expect(find.text('BLKWDS Manager'), findsOneWidget);
    });

    // More integration tests would be added here
  });
}
