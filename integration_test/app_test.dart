import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:blkwds_manager/main.dart' as app;

// Import our test files
import 'gear_checkout_flow_test.dart' as gear_checkout;
import 'booking_creation_flow_test.dart' as booking_creation;
import 'project_management_flow_test.dart' as project_management;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Basic Navigation Tests', () {
    testWidgets('Verify app launches and dashboard loads', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app title is displayed
      expect(find.text('BLKWDS Manager'), findsOneWidget);

      // Verify that the dashboard is loaded
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Recent Gear Activity'), findsOneWidget);
    });

    testWidgets('Navigate to Booking Panel and back', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find and tap the Open Booking Panel button
      await tester.tap(find.text('Open Booking Panel'));
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

    testWidgets('Navigate to Settings and back', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find and tap the Settings button
      final settingsButton = find.byIcon(Icons.settings);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Verify that we're on the Settings screen
      expect(find.text('Settings'), findsOneWidget);

      // Go back to the dashboard
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify that we're back on the dashboard
      expect(find.text('BLKWDS Manager'), findsOneWidget);
    });
  });

  // Run our critical user flow tests
  group('Critical User Flow Tests', () {
    gear_checkout.main();
    booking_creation.main();
    project_management.main();
  });
}
