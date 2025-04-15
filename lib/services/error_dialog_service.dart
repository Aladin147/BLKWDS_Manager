import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// ErrorAction enum
/// Represents possible actions for error dialogs
enum ErrorAction {
  ok('OK'),
  retry('Retry'),
  cancel('Cancel'),
  report('Report Issue');

  final String label;
  const ErrorAction(this.label);
}

/// ErrorDialogService
/// A centralized service for displaying error dialogs with multiple actions
class ErrorDialogService {
  /// Show an error dialog with the given title, message, and actions
  /// Returns the selected action, or null if the dialog was dismissed
  static Future<ErrorAction?> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    List<ErrorAction> actions = const [ErrorAction.ok],
  }) async {
    return await showDialog<ErrorAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: BLKWDSTypography.titleLarge.copyWith(
              color: BLKWDSColors.errorRed,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: BLKWDSColors.errorRed,
                  size: BLKWDSConstants.iconSizeLarge,
                ),
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                Text(
                  message,
                  style: BLKWDSTypography.bodyMedium.copyWith(
                    color: BLKWDSColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BLKWDSConstants.dialogBorderRadius),
          ),
          backgroundColor: BLKWDSColors.backgroundMedium,
          elevation: BLKWDSConstants.cardElevationMedium,
          actions: actions.map((action) {
            return TextButton(
              onPressed: () => Navigator.of(context).pop(action),
              style: TextButton.styleFrom(
                foregroundColor: _getActionColor(action),
                padding: const EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.buttonHorizontalPaddingMedium,
                  vertical: BLKWDSConstants.buttonVerticalPaddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.buttonBorderRadius),
                ),
              ),
              child: Text(
                action.label,
                style: BLKWDSTypography.labelLarge,
              ),
            );
          }).toList(),
          actionsPadding: const EdgeInsets.all(BLKWDSConstants.dialogPadding),
          buttonPadding: const EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.spacingXSmall,
          ),
        );
      },
    );
  }

  /// Show a warning dialog with the given title, message, and actions
  /// Returns the selected action, or null if the dialog was dismissed
  static Future<ErrorAction?> showWarningDialog(
    BuildContext context,
    String title,
    String message, {
    List<ErrorAction> actions = const [ErrorAction.ok, ErrorAction.cancel],
  }) async {
    return await showDialog<ErrorAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: BLKWDSTypography.titleLarge.copyWith(
              color: BLKWDSColors.warningAmber,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_outlined,
                  color: BLKWDSColors.warningAmber,
                  size: BLKWDSConstants.iconSizeLarge,
                ),
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                Text(
                  message,
                  style: BLKWDSTypography.bodyMedium.copyWith(
                    color: BLKWDSColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BLKWDSConstants.dialogBorderRadius),
          ),
          backgroundColor: BLKWDSColors.backgroundMedium,
          elevation: BLKWDSConstants.cardElevationMedium,
          actions: actions.map((action) {
            return TextButton(
              onPressed: () => Navigator.of(context).pop(action),
              style: TextButton.styleFrom(
                foregroundColor: _getActionColor(action),
                padding: const EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.buttonHorizontalPaddingMedium,
                  vertical: BLKWDSConstants.buttonVerticalPaddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.buttonBorderRadius),
                ),
              ),
              child: Text(
                action.label,
                style: BLKWDSTypography.labelLarge,
              ),
            );
          }).toList(),
          actionsPadding: const EdgeInsets.all(BLKWDSConstants.dialogPadding),
          buttonPadding: const EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.spacingXSmall,
          ),
        );
      },
    );
  }

  /// Get the appropriate color for an action button
  static Color _getActionColor(ErrorAction action) {
    switch (action) {
      case ErrorAction.ok:
        return BLKWDSColors.accentTeal;
      case ErrorAction.retry:
        return BLKWDSColors.accentTeal;
      case ErrorAction.cancel:
        return BLKWDSColors.textSecondary;
      case ErrorAction.report:
        return BLKWDSColors.warningAmber;
      default:
        return BLKWDSColors.accentTeal;
    }
  }
}
