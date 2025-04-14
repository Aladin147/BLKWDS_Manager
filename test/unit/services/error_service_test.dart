import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/services/error_service.dart';
import 'package:blkwds_manager/services/error_type.dart';

void main() {
  group('ErrorService Tests', () {
    test('getUserFriendlyMessage returns correct message for database errors', () {
      final error = Exception('Database error');
      final message = ErrorService.getUserFriendlyMessage(ErrorType.database, error);
      
      expect(message, 'There was an issue with the database. Please try again.');
    });

    test('getUserFriendlyMessage returns correct message for network errors', () {
      final error = Exception('Network error');
      final message = ErrorService.getUserFriendlyMessage(ErrorType.network, error);
      
      expect(message, 'Network error. Please check your connection and try again.');
    });

    test('getUserFriendlyMessage returns correct message for validation errors', () {
      final error = Exception('Validation error');
      final message = ErrorService.getUserFriendlyMessage(ErrorType.validation, error);
      
      expect(message, 'Please check your input and try again.');
    });

    test('getUserFriendlyMessage returns correct message for auth errors', () {
      final error = Exception('Auth error');
      final message = ErrorService.getUserFriendlyMessage(ErrorType.auth, error);
      
      expect(message, 'Authentication error. Please log in again.');
    });

    test('getUserFriendlyMessage returns correct message for unknown errors', () {
      final error = Exception('Unknown error');
      final message = ErrorService.getUserFriendlyMessage(ErrorType.unknown, error);
      
      expect(message, 'An unexpected error occurred. Please try again.');
    });

    test('handleError logs error and returns user-friendly message', () {
      final error = Exception('Test error');
      final message = ErrorService.handleError(error, type: ErrorType.database);
      
      expect(message, 'There was an issue with the database. Please try again.');
    });

    testWidgets('showErrorDialog displays dialog with correct message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorService.showErrorDialog(context, 'Test error message');
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      // Verify dialog is shown with correct message
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Tap OK to dismiss the dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.text('Error'), findsNothing);
    });

    testWidgets('showErrorSnackBar displays snackbar with correct message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorService.showErrorSnackBar(context, 'Test error message');
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show the snackbar
      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      // Verify snackbar is shown with correct message
      expect(find.text('Test error message'), findsOneWidget);
    });
  });
}
