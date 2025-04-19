import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:blkwds_manager/main.dart' as app;
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/services/db_service.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Gear Check-in/out Flow Test', () {
    testWidgets('Complete gear check-out and check-in flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Prepare test data
      await _prepareTestData();

      // Wait for the dashboard to load with improved stability
      await IntegrationTestHelpers.waitForAppStability(tester);

      // Verify that we're on the dashboard with retry logic
      final quickActionsFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Quick Actions');
      expect(quickActionsFinder, findsOneWidget);

      final recentActivityFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Recent Gear Activity');
      expect(recentActivityFinder, findsOneWidget);

      // Select a member from the dropdown with retry logic
      final dropdownFinder = await IntegrationTestHelpers.findByTypeWithRetry<DropdownButton<Member>>(tester);
      await IntegrationTestHelpers.tapWithRetry(tester, dropdownFinder);

      final memberFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Test Member');
      await IntegrationTestHelpers.tapWithRetry(tester, memberFinder.last);

      // Find a gear item in the list with retry logic
      final gearFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Test Camera');
      expect(gearFinder, findsOneWidget);

      // Check out the gear with retry logic
      final checkOutFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Check Out');
      await IntegrationTestHelpers.tapWithRetry(tester, checkOutFinder.first);

      // Add a note in the dialog with retry logic
      final textFieldFinder = await IntegrationTestHelpers.findByTypeWithRetry<TextField>(tester);
      await IntegrationTestHelpers.enterTextWithRetry(tester, textFieldFinder.last, 'Integration test checkout');

      // Confirm the check-out with retry logic
      final confirmFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Confirm');
      await IntegrationTestHelpers.tapWithRetry(tester, confirmFinder);

      // Wait for the gear status to be updated and verify
      await IntegrationTestHelpers.waitForWidget(
        tester,
        find.text('Check In'),
        timeout: const Duration(seconds: 5),
      );

      final checkInFinder = find.text('Check In');
      expect(checkInFinder, findsOneWidget);

      // Check in the gear with retry logic
      await IntegrationTestHelpers.tapWithRetry(tester, checkInFinder.first);

      // Add a note in the dialog with retry logic
      final textFieldFinder2 = await IntegrationTestHelpers.findByTypeWithRetry<TextField>(tester);
      await IntegrationTestHelpers.enterTextWithRetry(tester, textFieldFinder2.last, 'Integration test checkin');

      // Confirm the check-in with retry logic
      final confirmFinder2 = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Confirm');
      await IntegrationTestHelpers.tapWithRetry(tester, confirmFinder2);

      // Wait for the gear status to be updated again and verify
      await IntegrationTestHelpers.waitForWidget(
        tester,
        find.text('Check Out'),
        timeout: const Duration(seconds: 5),
      );

      final checkOutFinder2 = find.text('Check Out');
      expect(checkOutFinder2, findsOneWidget);

      // Clean up test data
      await _cleanupTestData();
    });

    testWidgets('Gear check-out with validation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Prepare test data
      await _prepareTestData();

      // Wait for the dashboard to load with improved stability
      await IntegrationTestHelpers.waitForAppStability(tester);

      // Verify that we're on the dashboard with retry logic
      final quickActionsFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Quick Actions');
      expect(quickActionsFinder, findsOneWidget);

      // Try to check out gear without selecting a member
      // Note: In the actual app, the member selection is managed in the DashboardScreen state
      // For testing purposes, we'll just try to tap the Check Out button without selecting a member
      // We need to reset the dropdown selection
      final dropdownFinder = await IntegrationTestHelpers.findByTypeWithRetry<DropdownButton<Member>>(tester);
      await IntegrationTestHelpers.tapWithRetry(tester, dropdownFinder);

      final selectMemberFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Select Member');
      await IntegrationTestHelpers.tapWithRetry(tester, selectMemberFinder.first);

      // Find a gear item in the list with retry logic
      final gearFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Test Camera');
      expect(gearFinder, findsOneWidget);

      // Check out the gear with retry logic
      final checkOutFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Check Out');
      await IntegrationTestHelpers.tapWithRetry(tester, checkOutFinder.first);

      // Verify that an error message is displayed with retry logic
      final errorFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Please select a member first');
      expect(errorFinder, findsOneWidget);

      // Clean up test data
      await _cleanupTestData();
    });
  });
}

// Helper method to prepare test data
Future<void> _prepareTestData() async {
  // Create a test member
  final member = Member(
    name: 'Test Member',
    role: 'Tester',
  );
  await DBService.insertMember(member);

  // Create a test gear item
  final gear = Gear(
    name: 'Test Camera',
    category: 'Camera',
    description: 'Test gear for integration testing',
    serialNumber: 'TEST123',
    isOut: false,
  );
  await DBService.insertGear(gear);
}

// Helper method to clean up test data
Future<void> _cleanupTestData() async {
  // Delete test data
  await DBService.deleteMemberByName('Test Member');
  await DBService.deleteGearByName('Test Camera');
}
