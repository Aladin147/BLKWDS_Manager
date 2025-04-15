import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// BLKWDSSnackbarType
/// Enum for snackbar types
enum BLKWDSSnackbarType {
  info,
  success,
  warning,
  error,
}

/// BLKWDSSnackbar
/// A standardized snackbar for the BLKWDS app
class BLKWDSSnackbar {
  /// Show a snackbar
  static void show({
    required BuildContext context,
    required String message,
    BLKWDSSnackbarType type = BLKWDSSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    // Get the color based on the type
    final Color backgroundColor;
    final Color textColor = Colors.white;
    final IconData icon;

    switch (type) {
      case BLKWDSSnackbarType.info:
        backgroundColor = BLKWDSColors.primaryButtonBackground;
        icon = Icons.info_outline;
        break;
      case BLKWDSSnackbarType.success:
        backgroundColor = BLKWDSColors.blkwdsGreen;
        icon = Icons.check_circle_outline;
        break;
      case BLKWDSSnackbarType.warning:
        backgroundColor = BLKWDSColors.warningAmber;
        icon = Icons.warning_amber_outlined;
        break;
      case BLKWDSSnackbarType.error:
        backgroundColor = BLKWDSColors.errorRed;
        icon = Icons.error_outline;
        break;
    }

    // Create the snackbar
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: BLKWDSConstants.spacingSmall),
          Expanded(
            child: Text(
              message,
              style: BLKWDSTypography.bodyMedium.copyWith(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
      ),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor,
              onPressed: onAction,
            )
          : null,
    );

    // Show the snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
