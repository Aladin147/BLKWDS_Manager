import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:blkwds_manager/main.dart' as app;
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/services/db_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Project Management Flow Test', () {
    testWidgets('Complete project management flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the dashboard to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Project Management
      await tester.tap(find.text('Manage Projects'));
      await tester.pumpAndSettle();

      // Verify that we're on the project management screen
      expect(find.text('Project Management'), findsOneWidget);

      // Click "Add Project"
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      // Verify that the project form is displayed
      expect(find.text('New Project'), findsOneWidget);

      // Fill in project details
      await tester.enterText(
        find.widgetWithText(TextField, 'Project Title'), 
        'Integration Test Project'
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Client'), 
        'Integration Test Client'
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Notes'), 
        'Project created during integration testing'
      );
      await tester.pumpAndSettle();

      // Save the project
      await tester.tap(find.text('Save Project'));
      await tester.pumpAndSettle();

      // Verify that the project was created successfully
      expect(find.text('Integration Test Project'), findsOneWidget);

      // Edit the project
      await tester.tap(find.text('Integration Test Project'));
      await tester.pumpAndSettle();

      // Verify that the project details are displayed
      expect(find.text('Edit Project'), findsOneWidget);

      // Update project details
      await tester.enterText(
        find.widgetWithText(TextField, 'Project Title'), 
        'Updated Integration Test Project'
      );
      await tester.pumpAndSettle();

      // Save the updated project
      await tester.tap(find.text('Save Project'));
      await tester.pumpAndSettle();

      // Verify that the project was updated successfully
      expect(find.text('Updated Integration Test Project'), findsOneWidget);

      // Delete the project
      await tester.longPress(find.text('Updated Integration Test Project'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify that the project was deleted successfully
      expect(find.text('Updated Integration Test Project'), findsNothing);

      // Clean up any remaining test data
      await _cleanupTestData();
    });

    testWidgets('Project creation with validation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the dashboard to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Project Management
      await tester.tap(find.text('Manage Projects'));
      await tester.pumpAndSettle();

      // Click "Add Project"
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      // Try to save without entering a title (required field)
      await tester.tap(find.text('Save Project'));
      await tester.pumpAndSettle();

      // Verify that validation error is displayed
      expect(find.text('Project title is required'), findsOneWidget);
    });
  });
}

// Helper method to clean up test data
Future<void> _cleanupTestData() async {
  // Delete test data
  await DBService.deleteProjectByTitle('Integration Test Project');
  await DBService.deleteProjectByTitle('Updated Integration Test Project');
}
