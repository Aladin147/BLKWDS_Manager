# [LEGACY] Error Handling Guidelines

> **WARNING**: This document is legacy documentation kept for historical reference.
> It may contain outdated information. Please refer to the current documentation in the main docs directory.
> Last updated: 2025-04-16


This document provides guidelines for using the BLKWDS Manager error handling system. Following these guidelines will ensure consistent error handling throughout the application.

## Overview

The BLKWDS Manager error handling system provides multiple mechanisms for handling errors and providing feedback to users:

1. **Toast Notifications**: Lightweight, non-intrusive messages for minor issues
2. **Snackbars**: More visible notifications with optional actions
3. **Dialogs**: Modal dialogs for critical errors that require user acknowledgment
4. **Banners**: Persistent messages for system-wide issues

## Error Types

The `ErrorType` enum defines the types of errors that can occur in the application:

| Error Type | Description | Default Feedback Level |
|------------|-------------|------------------------|
| `database` | Database-related errors | Dialog |
| `network` | Network connectivity issues | Dialog |
| `fileSystem` | File system access errors | Dialog |
| `state` | Application state errors | Dialog |
| `configuration` | Configuration errors | Dialog |
| `validation` | Input validation errors | Toast |
| `input` | User input errors | Toast |
| `format` | Data format errors | Toast |
| `conflict` | Data conflict errors | Snackbar |
| `notFound` | Resource not found errors | Snackbar |
| `permission` | Permission-related errors | Dialog |
| `auth` | Authentication errors | Dialog |
| `unknown` | Unclassified errors | Dialog |

## Exception Classes

The application provides custom exception classes for different error scenarios:

- `BLKWDSException`: Base class for all application exceptions
- `DatabaseException`: Database-related errors
- `NetworkException`: Network connectivity issues
- `FileSystemException`: File system access errors
- `ValidationException`: Input validation errors
- `PermissionException`: Permission-related errors
- `NotFoundException`: Resource not found errors
- `AuthException`: Authentication errors
- `ConfigurationException`: Configuration errors
- `StateException`: Application state errors

## Error Handling Services

### RetryService

The `RetryService` provides retry logic for operations that might fail:

```dart
// Retry with default strategy (immediate)
final result = await RetryService.retry(
  () => apiService.fetchData(),
  maxAttempts: 3,
);

// Retry with linear backoff
final result = await RetryService.retry(
  () => apiService.fetchData(),
  maxAttempts: 3,
  strategy: RetryStrategy.linear(delay: Duration(seconds: 1)),
);

// Retry with exponential backoff
final result = await RetryService.retry(
  () => apiService.fetchData(),
  maxAttempts: 3,
  strategy: RetryStrategy.exponential(initialDelay: Duration(milliseconds: 500)),
);

// Retry with callbacks
final result = await RetryService.retry(
  () => apiService.fetchData(),
  maxAttempts: 3,
  onRetry: (attempt, error, stackTrace) {
    LogService.info('Retry attempt $attempt after error: $error');
  },
  onSuccess: (result) {
    LogService.info('Operation succeeded after retries');
  },
  onFailure: (error, stackTrace) {
    LogService.error('Operation failed after all retry attempts', error, stackTrace);
  },
);
```

### RecoveryService

The `RecoveryService` provides fallback mechanisms for critical operations:

```dart
// Use fallback value if operation fails
final result = await RecoveryService.withFallback(
  () => apiService.fetchData(),
  fallback: () => defaultData,
);

// Use default value if operation fails
final result = await RecoveryService.withDefault(
  () => apiService.fetchData(),
  defaultValue: [],
);

// Attempt recovery if operation fails
final result = await RecoveryService.attemptRecovery(
  () => primaryOperation(),
  recoveryOperation: () => alternativeOperation(),
);
```

### ErrorAnalyticsService

The `ErrorAnalyticsService` provides error tracking and analytics:

```dart
// Track an error
await ErrorAnalyticsService.trackError(
  error,
  stackTrace: stackTrace,
  source: 'UserProfileScreen',
);

// Get error counts by type
final errorCounts = ErrorAnalyticsService.getErrorCountsByType();

// Get recent errors
final recentErrors = ErrorAnalyticsService.getRecentErrors(limit: 10);

// Export error log
final errorLog = ErrorAnalyticsService.exportErrorLogToJson();
```

### ContextualErrorHandler

The `ContextualErrorHandler` provides context-aware error handling:

```dart
// Handle a general error
ContextualErrorHandler.handleError(
  context,
  error,
  type: ErrorType.network, // Optional, will be determined automatically if not provided
  feedbackLevel: ErrorFeedbackLevel.dialog, // Optional, will be determined based on error type if not provided
  stackTrace: stackTrace, // Optional
);

// Handle a specific exception
ContextualErrorHandler.handleException(
  context,
  exception, // Must be a BLKWDSException
  feedbackLevel: ErrorFeedbackLevel.snackbar, // Optional
);
```

### FormErrorHandler

The `FormErrorHandler` provides form validation:

```dart
// Define validation rules
final rules = {
  'name': [
    RequiredRule(errorMessage: 'Name is required'),
    MinLengthRule(minLength: 3, errorMessage: 'Name must be at least 3 characters'),
  ],
  'email': [
    RequiredRule(),
    EmailRule(),
  ],
};

// Validate form data
final formData = {
  'name': nameController.text,
  'email': emailController.text,
};

// Get validation errors
final errors = FormErrorHandler.validateForm(formData, rules);

// Check if there are errors
if (errors.isNotEmpty) {
  // Handle errors
  final firstField = errors.keys.first;
  final firstError = errors[firstField]!;

  // Show error message
  SnackbarService.showError(context, '$firstField: $firstError');
  return;
}

// Proceed with form submission
```

### Feedback Services

#### ToastService

Use for lightweight, non-intrusive messages that automatically disappear:

```dart
// Show an error toast
ToastService.showError(context, 'Invalid email address');

// Show a success toast
ToastService.showSuccess(context, 'Profile updated successfully');

// Show a warning toast
ToastService.showWarning(context, 'Your session will expire soon');

// Show an info toast
ToastService.showInfo(context, 'New features are available');

// Customize position and duration
ToastService.show(
  context,
  'Custom toast message',
  type: ToastType.info,
  position: ToastPosition.top,
  duration: const Duration(seconds: 5),
);
```

#### SnackbarService

Use for more visible notifications that can include actions:

```dart
// Show an error snackbar
SnackbarService.showError(context, 'Failed to save changes');

// Show a success snackbar
SnackbarService.showSuccess(context, 'Changes saved successfully');

// Show a warning snackbar
SnackbarService.showWarning(context, 'This action cannot be undone');

// Show an info snackbar
SnackbarService.showInfo(context, 'Tap to view more details');

// Show a snackbar with an action
SnackbarService.show(
  context,
  'Connection lost',
  action: SnackBarAction(
    label: 'Retry',
    onPressed: () => reconnect(),
  ),
);
```

#### ErrorDialogService

Use for critical errors that require user acknowledgment:

```dart
// Show a simple error dialog
ErrorDialogService.showErrorDialog(context, 'Failed to connect to the server');

// Show a warning dialog
ErrorDialogService.showWarningDialog(
  context,
  'Warning',
  'This action will delete all your data',
);

// Show a custom error dialog with actions
ErrorDialogService.showCustomErrorDialog(
  context,
  'Connection Error',
  'Failed to connect to the server. Please check your internet connection and try again.',
  actions: [ErrorAction.retry, ErrorAction.cancel],
).then((action) {
  if (action == ErrorAction.retry) {
    // Handle retry
    reconnect();
  }
});
```

#### BannerService

Use for persistent messages that should remain visible until explicitly dismissed:

```dart
// Show an error banner
BannerService.showError(
  'System maintenance in progress',
  onDismiss: () {
    // Handle dismiss
    BannerService.hideBanner();
  },
);

// Show a warning banner
BannerService.showWarning(
  'Your subscription will expire soon',
  onDismiss: () {
    BannerService.hideBanner();
  },
  onRetry: () {
    // Handle retry
    navigateToSubscriptionPage();
  },
);

// Show an info banner
BannerService.showInfo(
  'New version available',
  onDismiss: () {
    BannerService.hideBanner();
  },
);
```

## UI Error Handling Components

### ErrorBoundary

The `ErrorBoundary` widget catches errors in its child widget tree and displays a fallback UI:

```dart
// Basic usage
ErrorBoundary(
  child: MyWidget(),
);

// With custom fallback widget
ErrorBoundary(
  child: MyWidget(),
  fallbackWidget: CustomErrorWidget(),
);

// With error tracking
ErrorBoundary(
  child: MyWidget(),
  errorSource: 'ProfileScreen',
  onError: (error, stackTrace) {
    LogService.error('UI error in ProfileScreen', error, stackTrace);
  },
);
```

### FallbackWidget

The `FallbackWidget` provides a standardized UI for different error states:

```dart
// Error fallback
FallbackWidget.error(
  message: 'Failed to load data',
  onRetry: loadData,
);

// Loading fallback
FallbackWidget.loading(
  message: 'Loading data...',
);

// Empty state fallback
FallbackWidget.empty(
  message: 'No items found',
  onPrimaryAction: addNewItem,
  primaryActionLabel: 'Add Item',
);

// No data fallback
FallbackWidget.noData(
  message: 'No data available',
  onRetry: refreshData,
);

// No connection fallback
FallbackWidget.noConnection(
  message: 'No internet connection',
  onRetry: checkConnection,
);
```

## When to Use Each Feedback Mechanism

### Toast Notifications

Use for:

- Minor validation errors
- Successful operations that don't require further action
- Informational messages that don't require user action
- Temporary status updates

Examples:

- "Invalid email format"
- "Profile updated successfully"
- "New message received"

### Snackbars

Use for:

- Operation results that might require action
- Non-critical errors that users should be aware of
- Warnings about potential issues
- Actions that can be undone

Examples:

- "Failed to load data. Tap to retry."
- "Item deleted. Undo?"
- "Changes saved successfully."

### Dialogs

Use for:

- Critical errors that prevent the application from functioning
- Actions that require explicit user confirmation
- Security-related issues
- Important information that must be acknowledged

Examples:

- "Failed to connect to the server. Please check your internet connection."
- "Are you sure you want to delete this item? This action cannot be undone."
- "Your session has expired. Please log in again."

### Banners

Use for:

- System-wide issues that affect the entire application
- Persistent warnings that should remain visible
- Important announcements
- Status information that should be continuously available

Examples:

- "System maintenance in progress. Some features may be unavailable."
- "You are currently offline. Changes will be saved locally."
- "Your subscription will expire in 3 days."

## Best Practices

1. **Be Consistent**: Use the same error handling mechanism for similar types of errors.
2. **Be Specific**: Provide clear, specific error messages that explain what went wrong.
3. **Be Helpful**: Include guidance on how to resolve the error when possible.
4. **Be Contextual**: Use the appropriate feedback level based on the severity and context of the error.
5. **Log Everything**: Always log errors, even if they are not shown to the user.
6. **Handle Gracefully**: Catch exceptions at appropriate levels and provide fallbacks when possible.
7. **Provide Recovery Options**: When appropriate, offer ways for users to recover from errors.
8. **Use Retry Logic**: Implement retry logic for operations that might fail due to temporary issues.
9. **Implement Fallbacks**: Provide fallback mechanisms for critical operations.
10. **Use Error Boundaries**: Wrap UI components with error boundaries to prevent the entire application from crashing.
11. **Track Errors**: Use error analytics to track and analyze errors for future improvements.

## Implementation Examples

### Example 1: Form Validation

```dart
void validateAndSubmitForm() {
  try {
    // Define validation rules
    final rules = {
      'name': [RequiredRule(), MinLengthRule(minLength: 3)],
      'email': [RequiredRule(), EmailRule()],
    };

    // Get form data
    final formData = {
      'name': nameController.text,
      'email': emailController.text,
    };

    // Validate form
    final errors = FormErrorHandler.validateForm(formData, rules);

    // Check for errors
    if (errors.isNotEmpty) {
      // Get the first error
      final firstField = errors.keys.first;
      final firstError = errors[firstField]!;

      // Show error as toast (minor issue)
      ToastService.showError(context, '$firstField: $firstError');
      return;
    }

    // Submit form
    submitForm(formData);

    // Show success message
    ToastService.showSuccess(context, 'Form submitted successfully');
  } catch (e, stackTrace) {
    // Handle unexpected errors
    ContextualErrorHandler.handleError(
      context,
      e,
      stackTrace: stackTrace,
    );
  }
}
```

### Example 2: API Request

```dart
Future<void> fetchData() async {
  try {
    // Show loading indicator
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Make API request
    final response = await apiService.getData();

    // Process response
    setState(() {
      data = response;
      isLoading = false;
    });

    // Show success message
    SnackbarService.showSuccess(context, 'Data loaded successfully');
  } on NetworkException catch (e) {
    // Handle network errors
    setState(() {
      isLoading = false;
      errorMessage = e.message;
    });

    // Show error with retry option
    SnackbarService.show(
      context,
      e.message,
      action: SnackBarAction(
        label: 'Retry',
        onPressed: fetchData,
      ),
    );
  } on NotFoundException catch (e) {
    // Handle not found errors
    setState(() {
      isLoading = false;
      errorMessage = e.message;
    });

    // Show error message
    ToastService.showError(context, e.message);
  } catch (e, stackTrace) {
    // Handle unexpected errors
    setState(() {
      isLoading = false;
      errorMessage = 'An unexpected error occurred';
    });

    // Use contextual error handler
    ContextualErrorHandler.handleError(
      context,
      e,
      stackTrace: stackTrace,
    );
  }
}
```

### Example 3: Critical System Error

```dart
void initializeSystem() async {
  try {
    // Initialize system components
    await databaseService.initialize();
    await authService.initialize();
    await fileService.initialize();

    // System initialized successfully
    LogService.info('System initialized successfully');
  } on DatabaseException catch (e) {
    // Handle database initialization error
    LogService.error('Database initialization failed', e, e.stackTrace);

    // Show persistent banner
    BannerService.showError(
      'Database initialization failed. Some features may be unavailable.',
      onRetry: () {
        BannerService.hideBanner();
        initializeSystem();
      },
    );

    // Show dialog with details
    ErrorDialogService.showErrorDialog(
      context,
      'Failed to initialize the database. ${e.message}',
    );
  } catch (e, stackTrace) {
    // Handle other initialization errors
    LogService.error('System initialization failed', e, stackTrace);

    // Show error dialog
    ErrorDialogService.showErrorDialog(
      context,
      'Failed to initialize the system. Please restart the application.',
    );
  }
}
```

## Conclusion

Following these guidelines will ensure consistent error handling throughout the application, providing a better user experience and making the application more robust and maintainable.

For more details on the implementation of the error handling system, refer to the following files:

- `lib/services/error_service.dart`
- `lib/services/error_type.dart`
- `lib/services/contextual_error_handler.dart`
- `lib/services/form_error_handler.dart`
- `lib/services/toast_service.dart`
- `lib/services/snackbar_service.dart`
- `lib/services/error_dialog_service.dart`
- `lib/services/banner_service.dart`
- `lib/services/exceptions/exceptions.dart`
- `lib/services/retry_service.dart`
- `lib/services/retry_strategy.dart`
- `lib/services/recovery_service.dart`
- `lib/services/error_analytics_service.dart`
- `lib/widgets/error_boundary.dart`
- `lib/widgets/fallback_widget.dart`
