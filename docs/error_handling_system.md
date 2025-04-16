# Error Handling System

**Version:** 1.0.0
**Last Updated:** 2025-06-10
**Status:** Implemented

## Overview

The BLKWDS Manager application implements a comprehensive error handling system that provides consistent error feedback, recovery mechanisms, and error logging throughout the application. This document provides an overview of the error handling system and how it is used in the application.

## Components

### 1. Error Types

The application uses a standardized set of error types defined in the `ErrorType` enum:

- `database` - Database-related errors
- `network` - Network-related errors
- `validation` - Input validation errors
- `auth` - Authentication and authorization errors
- `conflict` - Resource conflict errors
- `format` - Data format errors
- `fileSystem` - File system errors
- `state` - Application state errors
- `unknown` - Unknown errors

### 2. Error Feedback Levels

The application provides different levels of error feedback based on the severity and context of the error:

- `silent` - No user feedback, only logging
- `toast` - Lightweight toast notification
- `snackbar` - Snackbar notification with action
- `dialog` - Modal dialog with actions
- `banner` - Persistent error banner

### 3. Core Services

#### ContextualErrorHandler

The `ContextualErrorHandler` provides context-aware error handling with appropriate user feedback:

```dart
ContextualErrorHandler.handleError(
  context,
  error,
  type: ErrorType.database,
  stackTrace: stackTrace,
  feedbackLevel: ErrorFeedbackLevel.snackbar,
);
```

#### ErrorService

The `ErrorService` provides centralized error handling with user-friendly messages:

```dart
final message = ErrorService.handleError(
  error,
  type: ErrorType.database,
  stackTrace: stackTrace,
);
```

#### RetryService

The `RetryService` provides retry logic for operations that might fail:

```dart
final result = await RetryService.retry<List<Booking>>(
  operation: () => DBService.getAllBookings(),
  maxAttempts: 3,
  strategy: RetryStrategy.exponential,
  initialDelay: const Duration(milliseconds: 500),
  retryCondition: RetryService.isRetryableError,
);
```

#### RecoveryService

The `RecoveryService` provides recovery mechanisms for critical operations:

```dart
final result = await RecoveryService.withFallback<List<Booking>>(
  operation: () => DBService.getAllBookings(),
  fallback: () => _loadBookingsFromCache(),
  shouldUseFallback: (e) => e is DatabaseException,
);
```

#### LogService

The `LogService` provides structured logging with different log levels:

```dart
LogService.error('Error loading bookings', error, stackTrace);
```

### 4. UI Components

#### SnackbarService

The `SnackbarService` provides consistent snackbar notifications:

```dart
SnackbarService.showError(context, 'Failed to load bookings');
```

#### ErrorDialogService

The `ErrorDialogService` provides standardized error dialogs:

```dart
ErrorDialogService.showError(
  context,
  title: 'Database Error',
  message: 'Failed to load bookings',
  actions: [
    ErrorDialogAction(
      label: 'Retry',
      onPressed: () => _loadBookings(),
    ),
  ],
);
```

#### BannerService

The `BannerService` provides persistent error banners:

```dart
BannerService.showErrorBanner(
  context,
  message: 'Database connection lost',
  action: BannerAction(
    label: 'Reconnect',
    onPressed: () => _reconnectDatabase(),
  ),
);
```

## Integration in Controllers

All controllers in the application have been updated to use the error handling system. Here's an example of how error handling is implemented in a controller:

```dart
Future<void> loadData() async {
  try {
    // Show loading state
    isLoading.value = true;
    errorMessage.value = null;
    
    // Use retry logic for database operations
    final data = await RetryService.retry<List<Data>>(
      operation: () => DBService.getData(),
      maxAttempts: 3,
      strategy: RetryStrategy.exponential,
      initialDelay: const Duration(milliseconds: 500),
      retryCondition: RetryService.isRetryableError,
    );
    
    // Update state
    this.data.value = data;
  } catch (e, stackTrace) {
    // Update error state
    errorMessage.value = ErrorService.handleError(e, stackTrace: stackTrace);
    
    // Use contextual error handler if context is available
    if (context != null) {
      ContextualErrorHandler.handleError(
        context!,
        e,
        stackTrace: stackTrace,
        type: ErrorType.database,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      );
    } else {
      LogService.error('Error loading data', e, stackTrace);
    }
  } finally {
    // Update loading state
    isLoading.value = false;
  }
}
```

## Best Practices

1. **Use Appropriate Error Types**: Always use the most specific error type for the error being handled.
2. **Provide Context**: Include relevant context in error messages to help users understand what went wrong.
3. **Use Appropriate Feedback Levels**: Use the appropriate feedback level based on the severity and context of the error.
4. **Implement Retry Logic**: Use retry logic for operations that might fail due to temporary issues.
5. **Provide Recovery Options**: Offer recovery options when appropriate to help users recover from errors.
6. **Log All Errors**: Always log errors with appropriate context and stack traces for debugging.
7. **Show Success Messages**: Provide feedback for successful operations to improve user experience.

## Conclusion

The error handling system provides a robust foundation for handling errors throughout the application. By following the best practices outlined in this document, developers can ensure consistent error handling and a better user experience.
