import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/screens/dashboard/dashboard_screen.dart';
import '../test_helpers.dart';

void main() {
  setUpAll(() {
    initializeTestEnvironment();
  });

  group('Dashboard Screen Tests', () {
    testWidgets('Dashboard screen renders title correctly', (WidgetTester tester) async {
      // Build the dashboard screen
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      // Verify that the app title is displayed
      expect(find.text('BLKWDS Manager'), findsOneWidget);
    });

    testWidgets('Dashboard screen shows loading indicator initially', (WidgetTester tester) async {
      // Build the dashboard screen
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      // Verify that loading indicators are shown initially
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    // More widget tests would be added here
  });
}
