import 'package:flutter/material.dart';
import '../services/snackbar_service.dart';

/// BLKWDSSnackbarType
/// Enum for snackbar types
/// @deprecated Use SnackbarService instead
enum BLKWDSSnackbarType {
  info,
  success,
  warning,
  error,
}

/// BLKWDSSnackbar
/// A standardized snackbar for the BLKWDS app
/// @deprecated Use SnackbarService instead. This class will be removed in a future version.
class BLKWDSSnackbar {
  /// Show a snackbar
  /// @deprecated Use SnackbarService instead
  static void show({
    required BuildContext context,
    required String message,
    BLKWDSSnackbarType type = BLKWDSSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    // Forward to SnackbarService for consistent behavior
    if (onAction != null && actionLabel != null) {
      final action = SnackBarAction(
        label: actionLabel,
        onPressed: onAction,
      );

      switch (type) {
        case BLKWDSSnackbarType.info:
          return SnackbarService.showInfo(context, message, action: action, duration: duration);
        case BLKWDSSnackbarType.success:
          return SnackbarService.showSuccess(context, message, action: action, duration: duration);
        case BLKWDSSnackbarType.warning:
          return SnackbarService.showWarning(context, message, action: action, duration: duration);
        case BLKWDSSnackbarType.error:
          return SnackbarService.showError(context, message, action: action, duration: duration);
      }
    } else {
      switch (type) {
        case BLKWDSSnackbarType.info:
          return SnackbarService.showInfo(context, message, duration: duration);
        case BLKWDSSnackbarType.success:
          return SnackbarService.showSuccess(context, message, duration: duration);
        case BLKWDSSnackbarType.warning:
          return SnackbarService.showWarning(context, message, duration: duration);
        case BLKWDSSnackbarType.error:
          return SnackbarService.showError(context, message, duration: duration);
      }
    }
  }
}
