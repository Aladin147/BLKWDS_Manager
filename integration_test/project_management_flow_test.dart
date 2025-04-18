import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:blkwds_manager/main.dart' as app;
import 'package:blkwds_manager/services/db_service.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Project Management Flow Test', () {
    testWidgets('Complete project management flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the dashboard to load with improved stability
      await IntegrationTestHelpers.waitForAppStability(tester);

      // Navigate to Project Management with retry logic
      final manageProjectsFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Manage Projects');
      await IntegrationTestHelpers.tapWithRetry(tester, manageProjectsFinder);

      // Verify that we're on the project management screen with retry logic
      final projectManagementFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Project Management');
      expect(projectManagementFinder, findsOneWidget);

      // Click "Add Project" with retry logic
      final addProjectFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Add Project');
      await IntegrationTestHelpers.tapWithRetry(tester, addProjectFinder);

      // Verify that the project form is displayed with retry logic
      final newProjectFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'New Project');
      expect(newProjectFinder, findsOneWidget);

      // Fill in project details with retry logic
      final titleFieldFinder = find.widgetWithText(TextField, 'Project Title');
      await IntegrationTestHelpers.enterTextWithRetry(tester, titleFieldFinder, 'Integration Test Project');

      final clientFieldFinder = find.widgetWithText(TextField, 'Client');
      await IntegrationTestHelpers.enterTextWithRetry(tester, clientFieldFinder, 'Integration Test Client');

      final notesFieldFinder = find.widgetWithText(TextField, 'Notes');
      await IntegrationTestHelpers.enterTextWithRetry(tester, notesFieldFinder, 'Project created during integration testing');

      // Save the project with retry logic
      final saveProjectFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Save Project');
      await IntegrationTestHelpers.tapWithRetry(tester, saveProjectFinder);

      // Verify that the project was created successfully with retry logic
      final projectTitleFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Integration Test Project');
      expect(projectTitleFinder, findsOneWidget);

      // Edit the project with retry logic
      await IntegrationTestHelpers.tapWithRetry(tester, projectTitleFinder);

      // Verify that the project details are displayed with retry logic
      final editProjectFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Edit Project');
      expect(editProjectFinder, findsOneWidget);

      // Update project details with retry logic
      final updateTitleFieldFinder = find.widgetWithText(TextField, 'Project Title');
      await IntegrationTestHelpers.enterTextWithRetry(tester, updateTitleFieldFinder, 'Updated Integration Test Project');

      // Save the updated project with retry logic
      final saveUpdatedProjectFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Save Project');
      await IntegrationTestHelpers.tapWithRetry(tester, saveUpdatedProjectFinder);

      // Verify that the project was updated successfully with retry logic
      final updatedProjectTitleFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Updated Integration Test Project');
      expect(updatedProjectTitleFinder, findsOneWidget);

      // Delete the project with retry logic
      await tester.longPress(updatedProjectTitleFinder);
      await IntegrationTestHelpers.waitForAppStability(tester);

      final deleteFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Delete');
      await IntegrationTestHelpers.tapWithRetry(tester, deleteFinder);

      // Confirm deletion with retry logic
      final confirmDeleteFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Confirm');
      await IntegrationTestHelpers.tapWithRetry(tester, confirmDeleteFinder);
      await IntegrationTestHelpers.waitForAppStability(tester);

      // Verify that the project was deleted successfully
      // We need to wait a bit to ensure the UI has updated after deletion
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Updated Integration Test Project'), findsNothing);

      // Clean up any remaining test data
      await _cleanupTestData();
    });

    testWidgets('Project creation with validation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the dashboard to load with improved stability
      await IntegrationTestHelpers.waitForAppStability(tester);

      // Navigate to Project Management with retry logic
      final manageProjectsFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Manage Projects');
      await IntegrationTestHelpers.tapWithRetry(tester, manageProjectsFinder);

      // Click "Add Project" with retry logic
      final addProjectFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Add Project');
      await IntegrationTestHelpers.tapWithRetry(tester, addProjectFinder);

      // Try to save without entering a title (required field) with retry logic
      final saveProjectFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Save Project');
      await IntegrationTestHelpers.tapWithRetry(tester, saveProjectFinder);

      // Verify that validation error is displayed with retry logic
      final errorFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Project title is required');
      expect(errorFinder, findsOneWidget);
    });
  });
}

// Helper method to clean up test data
Future<void> _cleanupTestData() async {
  // Delete test data
  await DBService.deleteProjectByTitle('Integration Test Project');
  await DBService.deleteProjectByTitle('Updated Integration Test Project');
}
