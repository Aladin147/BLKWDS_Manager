import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Error banner widget
///
/// Displays a persistent banner for critical system errors
class BLKWDSErrorBanner extends StatelessWidget {
  /// The error message to display
  final String message;

  /// The callback when the retry button is pressed
  final VoidCallback? onRetry;

  /// The callback when the dismiss button is pressed
  final VoidCallback? onDismiss;

  /// Whether to show a retry button
  final bool showRetryButton;

  /// Whether to show a dismiss button
  final bool showDismissButton;

  /// The icon to display
  final IconData icon;

  /// The background color of the banner
  final Color backgroundColor;

  /// The text color of the banner
  final Color textColor;

  /// The icon color of the banner
  final Color iconColor;

  /// Create a new BLKWDSErrorBanner
  ///
  /// [message] is the error message to display
  /// [onRetry] is the callback when the retry button is pressed
  /// [onDismiss] is the callback when the dismiss button is pressed
  /// [showRetryButton] is whether to show a retry button
  /// [showDismissButton] is whether to show a dismiss button
  /// [icon] is the icon to display
  /// [backgroundColor] is the background color of the banner
  /// [textColor] is the text color of the banner
  /// [iconColor] is the icon color of the banner
  const BLKWDSErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.showRetryButton = true,
    this.showDismissButton = true,
    this.icon = Icons.error_outline,
    this.backgroundColor = BLKWDSColors.errorRed,
    this.textColor = BLKWDSColors.white,
    this.iconColor = BLKWDSColors.white,
  });

  /// Create a new error banner
  factory BLKWDSErrorBanner.error({
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = true,
    bool showDismissButton = true,
  }) {
    return BLKWDSErrorBanner(
      message: message,
      onRetry: onRetry,
      onDismiss: onDismiss,
      showRetryButton: showRetryButton,
      showDismissButton: showDismissButton,
      icon: Icons.error_outline,
      backgroundColor: BLKWDSColors.errorRed.withValues(alpha: 40),
      textColor: BLKWDSColors.errorRed,
      iconColor: BLKWDSColors.errorRed,
    );
  }

  /// Create a new warning banner
  factory BLKWDSErrorBanner.warning({
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = true,
    bool showDismissButton = true,
  }) {
    return BLKWDSErrorBanner(
      message: message,
      onRetry: onRetry,
      onDismiss: onDismiss,
      showRetryButton: showRetryButton,
      showDismissButton: showDismissButton,
      icon: Icons.warning_amber_outlined,
      backgroundColor: BLKWDSColors.warningAmber.withValues(alpha: 40),
      textColor: BLKWDSColors.warningAmber,
      iconColor: BLKWDSColors.warningAmber,
    );
  }

  /// Create a new info banner
  factory BLKWDSErrorBanner.info({
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = false,
    bool showDismissButton = true,
  }) {
    return BLKWDSErrorBanner(
      message: message,
      onRetry: onRetry,
      onDismiss: onDismiss,
      showRetryButton: showRetryButton,
      showDismissButton: showDismissButton,
      icon: Icons.info_outline,
      backgroundColor: BLKWDSColors.accentTeal.withValues(alpha: 40),
      textColor: BLKWDSColors.accentTeal,
      iconColor: BLKWDSColors.accentTeal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadiusSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Icon(
            icon,
            color: iconColor,
            size: BLKWDSConstants.iconSizeMedium,
          ),
          const SizedBox(width: BLKWDSConstants.spacingMedium),

          // Message
          Expanded(
            child: Text(
              message,
              style: BLKWDSTypography.bodyMedium.copyWith(
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: BLKWDSConstants.spacingMedium),

          // Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Retry button
              if (showRetryButton && onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: BLKWDSConstants.spacingMedium,
                      vertical: BLKWDSConstants.spacingXSmall,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        BLKWDSConstants.borderRadiusSmall,
                      ),
                    ),
                  ),
                  child: const Text('Retry'),
                ),

              // Dismiss button
              if (showDismissButton && onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close,
                      color: textColor,
                      size: BLKWDSConstants.iconSizeSmall,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
