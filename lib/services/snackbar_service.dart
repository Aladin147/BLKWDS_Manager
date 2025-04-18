import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

// Enum for snackbar types (internal use)
enum _SnackbarType {
  info,
  success,
  warning,
  error,
}

/// SnackbarService
/// A centralized service for displaying consistent snackbar messages
///
/// This service provides methods for showing different types of snackbars:
/// - Error: Red background with error icon
/// - Success: Green background with check icon
/// - Warning: Amber background with warning icon
/// - Info: Teal background with info icon
///
/// Each type has two variants:
/// - Basic: Just shows the message
/// - With Action: Includes a button for user interaction
///
/// Usage:
/// ```dart
/// // Show a basic error message
/// SnackbarService.showError(context, 'Something went wrong');
///
/// // Show a success message with an action
/// SnackbarService.showSuccess(
///   context,
///   'Item saved successfully',
///   action: SnackBarAction(
///     label: 'View',
///     onPressed: () => navigateToItem(),
///   ),
/// );
/// ```
class SnackbarService {
  /// Global key for the ScaffoldMessenger
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(debugLabel: 'SnackbarServiceKey');

  /// Show an error snackbar
  static void showError(BuildContext context, String message, {SnackBarAction? action, Duration? duration}) {
    _show(
      context: context,
      message: message,
      type: _SnackbarType.error,
      action: action,
      duration: duration,
    );
  }

  /// Show a success snackbar
  static void showSuccess(BuildContext context, String message, {SnackBarAction? action, Duration? duration}) {
    _show(
      context: context,
      message: message,
      type: _SnackbarType.success,
      action: action,
      duration: duration,
    );
  }

  /// Show a warning snackbar
  static void showWarning(BuildContext context, String message, {SnackBarAction? action, Duration? duration}) {
    _show(
      context: context,
      message: message,
      type: _SnackbarType.warning,
      action: action,
      duration: duration,
    );
  }

  /// Show an info snackbar
  static void showInfo(BuildContext context, String message, {SnackBarAction? action, Duration? duration}) {
    _show(
      context: context,
      message: message,
      type: _SnackbarType.info,
      action: action,
      duration: duration,
    );
  }

  /// @deprecated Use showError instead
  /// Show an error snackbar with action
  static void showErrorSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    showError(context, message, action: action);
  }

  /// @deprecated Use showSuccess instead
  /// Show a success snackbar with action
  static void showSuccessSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    showSuccess(context, message, action: action);
  }

  /// @deprecated Use showWarning instead
  /// Show a warning snackbar with action
  static void showWarningSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    showWarning(context, message, action: action);
  }

  /// @deprecated Use showInfo instead
  /// Show an info snackbar with action
  static void showInfoSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    showInfo(context, message, action: action);
  }

  /// Show an error snackbar without context
  static void showErrorGlobal(String message, {SnackBarAction? action, Duration? duration}) {
    _showGlobal(
      message: message,
      type: _SnackbarType.error,
      action: action,
      duration: duration,
    );
  }

  /// Show a success snackbar without context
  static void showSuccessGlobal(String message, {SnackBarAction? action, Duration? duration}) {
    _showGlobal(
      message: message,
      type: _SnackbarType.success,
      action: action,
      duration: duration,
    );
  }

  /// Show a warning snackbar without context
  static void showWarningGlobal(String message, {SnackBarAction? action, Duration? duration}) {
    _showGlobal(
      message: message,
      type: _SnackbarType.warning,
      action: action,
      duration: duration,
    );
  }

  /// Show an info snackbar without context
  static void showInfoGlobal(String message, {SnackBarAction? action, Duration? duration}) {
    _showGlobal(
      message: message,
      type: _SnackbarType.info,
      action: action,
      duration: duration,
    );
  }

  /// Show a snackbar with the given type and message
  /// This method consolidates functionality from both SnackbarService and BLKWDSSnackbar
  static void _show({
    required BuildContext context,
    required String message,
    required _SnackbarType type,
    SnackBarAction? action,
    Duration? duration,
  }) {
    // Get the color and icon based on the type
    final Color backgroundColor;
    final IconData icon;

    switch (type) {
      case _SnackbarType.info:
        backgroundColor = BLKWDSColors.accentTeal;
        icon = Icons.info_outline;
        break;
      case _SnackbarType.success:
        backgroundColor = BLKWDSColors.successGreen;
        icon = Icons.check_circle_outline;
        break;
      case _SnackbarType.warning:
        backgroundColor = BLKWDSColors.warningAmber;
        icon = Icons.warning_amber_outlined;
        break;
      case _SnackbarType.error:
        backgroundColor = BLKWDSColors.errorRed;
        icon = Icons.error_outline;
        break;
    }

    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Show the new snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: BLKWDSConstants.spacingSmall),
            Expanded(
              child: Text(
                message,
                style: BLKWDSTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration ?? BLKWDSConstants.snackbarDuration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        ),
        action: action ?? SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show a snackbar with the given type and message using the global key
  static void _showGlobal({
    required String message,
    required _SnackbarType type,
    SnackBarAction? action,
    Duration? duration,
  }) {
    // Check if the scaffold messenger key has a current state
    if (scaffoldMessengerKey.currentState == null) {
      return;
    }

    // Get the color and icon based on the type
    final Color backgroundColor;
    final IconData icon;

    switch (type) {
      case _SnackbarType.info:
        backgroundColor = BLKWDSColors.accentTeal;
        icon = Icons.info_outline;
        break;
      case _SnackbarType.success:
        backgroundColor = BLKWDSColors.successGreen;
        icon = Icons.check_circle_outline;
        break;
      case _SnackbarType.warning:
        backgroundColor = BLKWDSColors.warningAmber;
        icon = Icons.warning_amber_outlined;
        break;
      case _SnackbarType.error:
        backgroundColor = BLKWDSColors.errorRed;
        icon = Icons.error_outline;
        break;
    }

    // Dismiss any existing snackbars
    scaffoldMessengerKey.currentState!.hideCurrentSnackBar();

    // Show the new snackbar
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: BLKWDSConstants.spacingSmall),
            Expanded(
              child: Text(
                message,
                style: BLKWDSTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration ?? BLKWDSConstants.snackbarDuration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        ),
        action: action ?? SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
