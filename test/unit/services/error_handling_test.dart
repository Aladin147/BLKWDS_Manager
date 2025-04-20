import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:blkwds_manager/services/error_service.dart';
import 'package:blkwds_manager/services/error_feedback_level.dart';
import 'package:blkwds_manager/services/error_type.dart';
import 'package:blkwds_manager/services/contextual_error_handler.dart';
import 'package:blkwds_manager/services/snackbar_service.dart';

@GenerateMocks([BuildContext, SnackbarService])
import 'error_handling_test.mocks.dart';

void main() {
  group('ErrorService', () {
    test('should get user-friendly error messages', () {
      // Arrange
      final testError = Exception('Test error');

      // Act
      final message = ErrorService.getUserFriendlyMessage(ErrorType.database, testError);

      // Assert
      expect(message, 'There was an issue with the database. Please try again.');
    });

    test('should handle errors and return user-friendly messages', () {
      // Arrange
      final testError = Exception('Test error');
      final testStackTrace = StackTrace.current;

      // Act
      final message = ErrorService.handleError(testError, type: ErrorType.network, stackTrace: testStackTrace);

      // Assert
      expect(message, 'Network error. Please check your connection and try again.');
    });

    test('should determine error type from error object', () {
      // Arrange & Act
      final formatError = FormatException('Invalid format');
      final argumentError = ArgumentError('Invalid argument');
      final stateError = StateError('Invalid state');

      // Assert - using private method indirectly through handleError
      final formatMessage = ErrorService.handleError(formatError);
      final argumentMessage = ErrorService.handleError(argumentError);
      final stateMessage = ErrorService.handleError(stateError);

      expect(formatMessage, 'The data format is invalid. Please try again with a valid format.');
      expect(argumentMessage, 'Invalid input. Please check your input and try again.');
      expect(stateMessage, 'The application is in an invalid state. Please restart the application.');
    });
  });

  group('ContextualErrorHandler', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
      when(mockContext.widget).thenReturn(Container());
    });

    test('should determine appropriate feedback level for error types', () {
      // Act & Assert
      expect(ContextualErrorHandler.getFeedbackLevelForErrorType(ErrorType.database), ErrorFeedbackLevel.dialog);
      expect(ContextualErrorHandler.getFeedbackLevelForErrorType(ErrorType.validation), ErrorFeedbackLevel.snackbar);
      expect(ContextualErrorHandler.getFeedbackLevelForErrorType(ErrorType.conflict), ErrorFeedbackLevel.snackbar);
      expect(ContextualErrorHandler.getFeedbackLevelForErrorType(ErrorType.permission), ErrorFeedbackLevel.dialog);
      expect(ContextualErrorHandler.getFeedbackLevelForErrorType(ErrorType.unknown), ErrorFeedbackLevel.dialog);
    });

    test('should get user-friendly message for errors', () {
      // Arrange
      final testError = Exception('Test error');

      // Act - using private method indirectly through handleError
      // We can't directly test private methods, but we can observe their effects
      ContextualErrorHandler.handleError(
        mockContext,
        testError,
        type: ErrorType.database,
        feedbackLevel: ErrorFeedbackLevel.silent, // Use silent to avoid UI interactions
      );

      // No direct assertion possible since we can't access the private method's return value
      // This is more of a smoke test to ensure no exceptions are thrown
    });
  });
}
