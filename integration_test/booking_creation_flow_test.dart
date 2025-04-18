import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:blkwds_manager/main.dart' as app;
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/services/navigation_service.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Creation Flow Test', () {
    testWidgets('Complete booking creation flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Prepare test data
      await _prepareTestData();

      // Wait for the dashboard to load with improved stability
      await IntegrationTestHelpers.waitForAppStability(tester);

      // Navigate to Booking Panel with retry logic
      final bookingPanelButtonFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Open Booking Panel');
      await IntegrationTestHelpers.tapWithRetry(tester, bookingPanelButtonFinder);

      // Verify that we're on the booking panel with retry logic
      final bookingPanelTitleFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Booking Panel');
      expect(bookingPanelTitleFinder, findsOneWidget);

      // Click "Create New Booking" with retry logic
      final createBookingFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Create New Booking');
      await IntegrationTestHelpers.tapWithRetry(tester, createBookingFinder);

      // Verify that the booking form is displayed with retry logic
      final newBookingFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'New Booking');
      expect(newBookingFinder, findsOneWidget);

      // Select a project with retry logic
      final projectDropdownFinder = await IntegrationTestHelpers.findByTypeWithRetry<DropdownButton<Project>>(tester);
      await IntegrationTestHelpers.tapWithRetry(tester, projectDropdownFinder.first);

      final projectFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Test Project');
      await IntegrationTestHelpers.tapWithRetry(tester, projectFinder.last);

      // Set booking title with retry logic
      final titleFieldFinder = find.widgetWithText(TextField, 'Booking Title (optional)');
      await IntegrationTestHelpers.enterTextWithRetry(tester, titleFieldFinder, 'Test Booking');

      // Set start date and time
      // Note: Date/time pickers are complex to test in integration tests
      // For simplicity, we'll assume the default values are acceptable

      // Select gear items with retry logic
      final selectGearFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Select Gear');
      await IntegrationTestHelpers.tapWithRetry(tester, selectGearFinder);

      // Check the test gear item with retry logic
      final testCameraFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Test Camera');
      await IntegrationTestHelpers.tapWithRetry(tester, testCameraFinder);

      // Confirm gear selection with retry logic
      final confirmFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Confirm');
      await IntegrationTestHelpers.tapWithRetry(tester, confirmFinder);

      // Assign gear to members with retry logic
      final assignMembersFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Assign Members');
      await IntegrationTestHelpers.tapWithRetry(tester, assignMembersFinder);

      // Select a member for the gear with retry logic
      final testMemberFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Test Member');
      await IntegrationTestHelpers.tapWithRetry(tester, testMemberFinder);

      // Confirm member assignment with retry logic
      final confirmMemberFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Confirm');
      await IntegrationTestHelpers.tapWithRetry(tester, confirmMemberFinder);

      // Save the booking with retry logic
      final saveBookingFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Save Booking');
      await IntegrationTestHelpers.tapWithRetry(tester, saveBookingFinder);

      // Verify that the booking was created successfully with retry logic
      final testBookingFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Test Booking');
      expect(testBookingFinder, findsOneWidget);

      // Navigate back to dashboard and wait for stability
      NavigationService().navigateToDashboard();
      await IntegrationTestHelpers.waitForAppStability(tester);

      // Clean up test data
      await _cleanupTestData();
    });

    testWidgets('Booking creation with validation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the dashboard to load with improved stability
      await IntegrationTestHelpers.waitForAppStability(tester);

      // Navigate to Booking Panel with retry logic
      final bookingPanelButtonFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Open Booking Panel');
      await IntegrationTestHelpers.tapWithRetry(tester, bookingPanelButtonFinder);

      // Click "Create New Booking" with retry logic
      final createBookingFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Create New Booking');
      await IntegrationTestHelpers.tapWithRetry(tester, createBookingFinder);

      // Try to save without selecting a project (required field) with retry logic
      final saveBookingFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Save Booking');
      await IntegrationTestHelpers.tapWithRetry(tester, saveBookingFinder);

      // Verify that validation error is displayed with retry logic
      final errorFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Please select a project');
      expect(errorFinder, findsOneWidget);
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

  // Create a test project
  final project = Project(
    title: 'Test Project',
    client: 'Test Client',
    notes: 'Test project for integration testing',
  );
  await DBService.insertProject(project);

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
  await DBService.deleteProjectByTitle('Test Project');
  await DBService.deleteGearByName('Test Camera');
  await DBService.deleteBookingByTitle('Test Booking');
}
