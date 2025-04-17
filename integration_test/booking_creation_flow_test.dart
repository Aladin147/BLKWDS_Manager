import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:blkwds_manager/main.dart' as app;
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/services/navigation_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Creation Flow Test', () {
    testWidgets('Complete booking creation flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Prepare test data
      await _prepareTestData();

      // Wait for the dashboard to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Booking Panel
      await tester.tap(find.text('Open Booking Panel'));
      await tester.pumpAndSettle();

      // Verify that we're on the booking panel
      expect(find.text('Booking Panel'), findsOneWidget);

      // Click "Create New Booking"
      await tester.tap(find.text('Create New Booking'));
      await tester.pumpAndSettle();

      // Verify that the booking form is displayed
      expect(find.text('New Booking'), findsOneWidget);

      // Select a project
      await tester.tap(find.byType(DropdownButton<Project>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Project').last);
      await tester.pumpAndSettle();

      // Set booking title
      await tester.enterText(
        find.widgetWithText(TextField, 'Booking Title (optional)'), 
        'Test Booking'
      );
      await tester.pumpAndSettle();

      // Set start date and time
      // Note: Date/time pickers are complex to test in integration tests
      // For simplicity, we'll assume the default values are acceptable

      // Select gear items
      await tester.tap(find.text('Select Gear'));
      await tester.pumpAndSettle();

      // Check the test gear item
      await tester.tap(find.text('Test Camera'));
      await tester.pumpAndSettle();

      // Confirm gear selection
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Assign gear to members
      await tester.tap(find.text('Assign Members'));
      await tester.pumpAndSettle();

      // Select a member for the gear
      await tester.tap(find.text('Test Member'));
      await tester.pumpAndSettle();

      // Confirm member assignment
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Save the booking
      await tester.tap(find.text('Save Booking'));
      await tester.pumpAndSettle();

      // Verify that the booking was created successfully
      expect(find.text('Test Booking'), findsOneWidget);

      // Navigate back to dashboard
      NavigationService().navigateToDashboard();
      await tester.pumpAndSettle();

      // Clean up test data
      await _cleanupTestData();
    });

    testWidgets('Booking creation with validation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the dashboard to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Booking Panel
      await tester.tap(find.text('Open Booking Panel'));
      await tester.pumpAndSettle();

      // Click "Create New Booking"
      await tester.tap(find.text('Create New Booking'));
      await tester.pumpAndSettle();

      // Try to save without selecting a project (required field)
      await tester.tap(find.text('Save Booking'));
      await tester.pumpAndSettle();

      // Verify that validation error is displayed
      expect(find.text('Please select a project'), findsOneWidget);
    });
  });
}

// Helper method to prepare test data
Future<void> _prepareTestData() async {
  // Create a test member
  final member = Member(
    name: 'Test Member',
    role: 'Tester',
    email: 'test@example.com',
  );
  final memberId = await DBService.insertMember(member);

  // Create a test project
  final project = Project(
    title: 'Test Project',
    client: 'Test Client',
    notes: 'Test project for integration testing',
  );
  final projectId = await DBService.insertProject(project);

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
