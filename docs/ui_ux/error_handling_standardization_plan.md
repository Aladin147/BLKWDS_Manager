# Error Handling Standardization Implementation Plan

## Overview

This document outlines the implementation plan for standardizing error handling in the BLKWDS Manager application. The goal is to replace all direct ScaffoldMessenger calls and deprecated BLKWDSSnackbar usage with the centralized SnackbarService to ensure consistent error handling throughout the application.

## Current State

The application currently uses multiple approaches to error handling:

1. Direct ScaffoldMessenger calls
2. Deprecated BLKWDSSnackbar usage
3. SnackbarService (the preferred approach)

This inconsistency can lead to:
- Inconsistent user experience
- Potential memory leaks (if context is used after widget disposal)
- Code duplication
- Maintenance challenges

## Requirements

1. All error handling should use the centralized SnackbarService
2. No direct ScaffoldMessenger calls should remain in the codebase
3. No deprecated BLKWDSSnackbar usage should remain in the codebase
4. Error feedback levels should be consistent throughout the application
5. Proper context handling should be ensured to prevent setState after dispose errors

## Implementation Steps

### 1. Audit the Codebase

#### 1.1 Identify Direct ScaffoldMessenger Calls

Use static analysis tools to identify all direct ScaffoldMessenger calls in the codebase:

```bash
grep -r "ScaffoldMessenger.of(context)" --include="*.dart" lib/
```

Create a list of files that need to be updated:

| File | Line | Current Implementation | Required Action |
|------|------|------------------------|----------------|
| *To be filled during audit* | | | |

#### 1.2 Identify Deprecated BLKWDSSnackbar Usage

Use static analysis tools to identify all BLKWDSSnackbar usage in the codebase:

```bash
grep -r "BLKWDSSnackbar" --include="*.dart" lib/
```

Create a list of files that need to be updated:

| File | Line | Current Implementation | Required Action |
|------|------|------------------------|----------------|
| *To be filled during audit* | | | |

### 2. Update the SnackbarService

Ensure that the SnackbarService has all the functionality needed to replace direct ScaffoldMessenger calls and BLKWDSSnackbar usage:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/constants/blkwds_colors.dart';
import 'package:blkwds_manager/enums/error_feedback_level.dart';

class SnackbarService {
  static final SnackbarService _instance = SnackbarService._internal();

  factory SnackbarService() {
    return _instance;
  }

  SnackbarService._internal();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void showSnackbar({
    required String message,
    ErrorFeedbackLevel level = ErrorFeedbackLevel.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (scaffoldMessengerKey.currentState == null) {
      print('ScaffoldMessengerState is null. Cannot show snackbar.');
      return;
    }

    final Color backgroundColor = _getBackgroundColorForLevel(level);
    final Color textColor = _getTextColorForLevel(level);
    final IconData icon = _getIconForLevel(level);

    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  void showSuccessSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackbar(
      message: message,
      level: ErrorFeedbackLevel.success,
      duration: duration,
      action: action,
    );
  }

  void showErrorSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackbar(
      message: message,
      level: ErrorFeedbackLevel.error,
      duration: duration,
      action: action,
    );
  }

  void showWarningSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackbar(
      message: message,
      level: ErrorFeedbackLevel.warning,
      duration: duration,
      action: action,
    );
  }

  void showInfoSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackbar(
      message: message,
      level: ErrorFeedbackLevel.info,
      duration: duration,
      action: action,
    );
  }

  Color _getBackgroundColorForLevel(ErrorFeedbackLevel level) {
    switch (level) {
      case ErrorFeedbackLevel.success:
        return Colors.green;
      case ErrorFeedbackLevel.error:
        return Colors.red;
      case ErrorFeedbackLevel.warning:
        return Colors.orange;
      case ErrorFeedbackLevel.info:
        return BLKWDSColors.primary;
    }
  }

  Color _getTextColorForLevel(ErrorFeedbackLevel level) {
    return Colors.white;
  }

  IconData _getIconForLevel(ErrorFeedbackLevel level) {
    switch (level) {
      case ErrorFeedbackLevel.success:
        return Icons.check_circle;
      case ErrorFeedbackLevel.error:
        return Icons.error;
      case ErrorFeedbackLevel.warning:
        return Icons.warning;
      case ErrorFeedbackLevel.info:
        return Icons.info;
    }
  }
}
```

### 3. Update the ErrorFeedbackLevel Enum

Ensure that the ErrorFeedbackLevel enum is properly defined:

```dart
enum ErrorFeedbackLevel {
  success,
  error,
  warning,
  info,
}
```

### 4. Replace Direct ScaffoldMessenger Calls

For each file identified in step 1.1, replace direct ScaffoldMessenger calls with SnackbarService:

#### Before:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Some message'),
    backgroundColor: Colors.red,
  ),
);
```

#### After:

```dart
SnackbarService().showErrorSnackbar(
  message: 'Some message',
);
```

### 5. Replace Deprecated BLKWDSSnackbar Usage

For each file identified in step 1.2, replace deprecated BLKWDSSnackbar usage with SnackbarService:

#### Before:

```dart
BLKWDSSnackbar.show(
  context: context,
  message: 'Some message',
  type: BLKWDSSnackbarType.error,
);
```

#### After:

```dart
SnackbarService().showErrorSnackbar(
  message: 'Some message',
);
```

### 6. Ensure Proper Context Handling

For each file that uses context for error handling, ensure proper context handling to prevent setState after dispose errors:

#### Before:

```dart
Future<void> _someAsyncMethod() async {
  try {
    await _someService.doSomething();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Success'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

#### After:

```dart
Future<void> _someAsyncMethod() async {
  try {
    await _someService.doSomething();
    if (mounted) {
      SnackbarService().showSuccessSnackbar(
        message: 'Success',
      );
    }
  } catch (e) {
    if (mounted) {
      SnackbarService().showErrorSnackbar(
        message: 'Error: $e',
      );
    }
  }
}
```

### 7. Update the Main App Widget

Ensure that the main app widget uses the SnackbarService's scaffoldMessengerKey:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/services/snackbar_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: SnackbarService().scaffoldMessengerKey,
      // Other app configuration...
    );
  }
}
```

### 8. Test the Implementation

Test the error handling implementation to ensure it works correctly:

1. Verify that all direct ScaffoldMessenger calls have been replaced
2. Verify that all deprecated BLKWDSSnackbar usage has been replaced
3. Verify that error feedback levels are consistent throughout the application
4. Verify that proper context handling is in place to prevent setState after dispose errors
5. Test error handling in various scenarios to ensure it works correctly

## Implementation Schedule

| Task | Estimated Time | Dependencies |
|------|----------------|--------------|
| Audit the codebase | 2 hours | None |
| Update the SnackbarService | 1 hour | None |
| Update the ErrorFeedbackLevel enum | 0.5 hours | None |
| Replace direct ScaffoldMessenger calls | 3 hours | Audit, SnackbarService update |
| Replace deprecated BLKWDSSnackbar usage | 3 hours | Audit, SnackbarService update |
| Ensure proper context handling | 2 hours | Replacement of calls |
| Update the main app widget | 0.5 hours | SnackbarService update |
| Test the implementation | 2 hours | All previous tasks |
| **Total** | **14 hours** | |

## Conclusion

This implementation plan provides a comprehensive approach to standardizing error handling in the BLKWDS Manager application. By following this plan, we will ensure consistent error handling throughout the application, improving the user experience and making the codebase more maintainable.

## Next Steps

1. Conduct the codebase audit to identify all direct ScaffoldMessenger calls and deprecated BLKWDSSnackbar usage
2. Update the SnackbarService to ensure it has all the functionality needed
3. Replace all direct ScaffoldMessenger calls and deprecated BLKWDSSnackbar usage with SnackbarService
4. Ensure proper context handling to prevent setState after dispose errors
5. Test the implementation to ensure it works correctly
