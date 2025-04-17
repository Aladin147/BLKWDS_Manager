import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:blkwds_manager/main.dart' as app;
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/dashboard/dashboard_controller.dart';
import 'package:blkwds_manager/services/db_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Gear Check-in/out Flow Test', () {
    testWidgets('Complete gear check-out and check-in flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Prepare test data
      await _prepareTestData();

      // Wait for the dashboard to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify that we're on the dashboard
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Recent Gear Activity'), findsOneWidget);

      // Select a member from the dropdown
      await tester.tap(find.byType(DropdownButton<Member>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Member').last);
      await tester.pumpAndSettle();

      // Find a gear item in the list
      expect(find.text('Test Camera'), findsOneWidget);

      // Check out the gear
      await tester.tap(find.text('Check Out').first);
      await tester.pumpAndSettle();

      // Add a note in the dialog
      await tester.enterText(find.byType(TextField).last, 'Integration test checkout');
      await tester.pumpAndSettle();

      // Confirm the check-out
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify the gear status is updated (should now show "Check In" button)
      expect(find.text('Check In'), findsOneWidget);

      // Check in the gear
      await tester.tap(find.text('Check In').first);
      await tester.pumpAndSettle();

      // Add a note in the dialog
      await tester.enterText(find.byType(TextField).last, 'Integration test checkin');
      await tester.pumpAndSettle();

      // Confirm the check-in
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify the gear status is updated (should now show "Check Out" button again)
      expect(find.text('Check Out'), findsOneWidget);

      // Clean up test data
      await _cleanupTestData();
    });

    testWidgets('Gear check-out with validation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Prepare test data
      await _prepareTestData();

      // Wait for the dashboard to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify that we're on the dashboard
      expect(find.text('Quick Actions'), findsOneWidget);

      // Try to check out gear without selecting a member
      // First, clear the member selection if any
      final controller = DashboardController();
      controller.selectedMember.value = null;

      // Find a gear item in the list
      expect(find.text('Test Camera'), findsOneWidget);

      // Check out the gear
      await tester.tap(find.text('Check Out').first);
      await tester.pumpAndSettle();

      // Verify that an error message is displayed
      expect(find.text('Please select a member first'), findsOneWidget);

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
    email: 'test@example.com',
  );
  final memberId = await DBService.insertMember(member);

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
