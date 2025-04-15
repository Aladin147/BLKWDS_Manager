import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// SnackbarService
/// A centralized service for displaying consistent snackbar messages
class SnackbarService {
  /// Show an error snackbar
  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      BLKWDSColors.errorRed,
      Icons.error_outline,
    );
  }

  /// Show a success snackbar
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      BLKWDSColors.successGreen,
      Icons.check_circle_outline,
    );
  }

  /// Show a warning snackbar
  static void showWarning(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      BLKWDSColors.warningAmber,
      Icons.warning_amber_outlined,
    );
  }

  /// Show an info snackbar
  static void showInfo(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      BLKWDSColors.accentTeal,
      Icons.info_outline,
    );
  }

  /// Show an error snackbar with action
  static void showErrorSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    _showSnackbar(
      context,
      message,
      BLKWDSColors.errorRed,
      Icons.error_outline,
      action: action,
    );
  }

  /// Show a success snackbar with action
  static void showSuccessSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    _showSnackbar(
      context,
      message,
      BLKWDSColors.successGreen,
      Icons.check_circle_outline,
      action: action,
    );
  }

  /// Show a warning snackbar with action
  static void showWarningSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    _showSnackbar(
      context,
      message,
      BLKWDSColors.warningAmber,
      Icons.warning_amber_outlined,
      action: action,
    );
  }

  /// Show an info snackbar with action
  static void showInfoSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    _showSnackbar(
      context,
      message,
      BLKWDSColors.accentTeal,
      Icons.info_outline,
      action: action,
    );
  }

  /// Private method to show a snackbar with the given parameters
  static void _showSnackbar(
    BuildContext context,
    String message,
    Color color,
    IconData icon, {
    SnackBarAction? action,
  }) {
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
        backgroundColor: color,
        duration: BLKWDSConstants.snackbarDuration,
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
}
