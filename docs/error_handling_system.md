# Error Handling System

This document describes the standardized error handling system for the BLKWDS Manager application.

## 1. Overview

The error handling system provides a consistent approach to handling errors throughout the application. It includes:

- Centralized error handling services
- Standardized error feedback levels
- Consistent UI for error notifications
- Comprehensive error logging

## 2. Error Handling Services

### 2.1 ErrorService

The `ErrorService` is the primary service for handling errors. It provides methods for:

- Getting user-friendly error messages
- Handling errors with different feedback levels
- Showing error dialogs and snackbars

```dart
// Handle an error with a user-friendly message
final message = ErrorService.handleError(error, stackTrace: stackTrace);

// Handle an error with context-aware feedback
ErrorService.handleErrorWithFeedback(
  context,
  error,
  stackTrace: stackTrace,
  feedbackLevel: ErrorFeedbackLevel.snackbar,
);
```

### 2.2 ContextualErrorHandler

The `ContextualErrorHandler` provides context-aware error handling. It determines the appropriate feedback level based on the error type and context.

```dart
// Handle an error with context-aware feedback
ContextualErrorHandler.handleError(
  context,
  error,
  stackTrace: stackTrace,
  feedbackLevel: ErrorFeedbackLevel.snackbar,
);

// Handle a specific exception
ContextualErrorHandler.handleException(
  context,
  exception,
  feedbackLevel: ErrorFeedbackLevel.dialog,
);
```

## 3. Error Types

The `ErrorType` enum defines the different types of errors that can occur in the application:

- `database`: Database-related errors
- `network`: Network-related errors
- `validation`: Input validation errors
- `auth`: Authentication errors
- `fileSystem`: File system errors
- `permission`: Permission errors
- `format`: Data format errors
- `conflict`: Data conflict errors
- `notFound`: Resource not found errors
- `input`: User input errors
- `state`: Application state errors
- `configuration`: Configuration errors
- `unknown`: Unknown errors

## 4. Error Feedback Levels

The `ErrorFeedbackLevel` enum defines the different levels of feedback that can be provided to the user:

- `silent`: No feedback is provided to the user, but the error is still logged
- `snackbar`: A snackbar is shown to the user with the error message
- `dialog`: A dialog is shown to the user with the error message
- `banner`: A banner is shown at the top of the screen with the error message
- `page`: A full-screen error page is shown to the user

## 5. Best Practices

### 5.1 When to Use Each Feedback Level

- **Silent**: Use for non-critical errors that don't affect the user experience
- **Snackbar**: Use for transient errors that the user should be aware of
- **Dialog**: Use for critical errors that require user action
- **Banner**: Use for persistent errors that the user should be aware of
- **Page**: Use for fatal errors that prevent the application from functioning

### 5.2 Error Handling in Controllers

Controllers should use the `ContextualErrorHandler` to handle errors:

```dart
try {
  // Perform an operation
  await someOperation();
} catch (e, stackTrace) {
  // Handle the error
  ContextualErrorHandler.handleError(
    context,
    e,
    stackTrace: stackTrace,
    type: ErrorType.database,
    feedbackLevel: ErrorFeedbackLevel.snackbar,
  );
}
```

### 5.3 Error Handling in Services

Services should use the `LogService` to log errors and return appropriate error messages:

```dart
try {
  // Perform an operation
  await someOperation();
} catch (e, stackTrace) {
  // Log the error
  LogService.error('Error performing operation', e, stackTrace);
  
  // Rethrow the error for the controller to handle
  rethrow;
}
```

## 6. Migration Guide

To migrate from the old error handling approach to the new standardized approach:

1. Replace direct `ScaffoldMessenger` calls with `SnackbarService` calls
2. Replace `BLKWDSSnackbar` calls with `SnackbarService` calls
3. Use `ContextualErrorHandler` for context-aware error handling
4. Use `ErrorService` for centralized error handling

### 6.1 Before

```dart
try {
  // Perform an operation
  await someOperation();
} catch (e) {
  // Show an error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('An error occurred')),
  );
}
```

### 6.2 After

```dart
try {
  // Perform an operation
  await someOperation();
} catch (e, stackTrace) {
  // Handle the error
  ContextualErrorHandler.handleError(
    context,
    e,
    stackTrace: stackTrace,
    type: ErrorType.database,
    feedbackLevel: ErrorFeedbackLevel.snackbar,
  );
}
```

## 7. Conclusion

By following these guidelines, we can ensure a consistent and user-friendly approach to error handling throughout the application. This will improve the user experience and make the application more robust and maintainable.
