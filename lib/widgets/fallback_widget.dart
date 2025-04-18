import 'package:flutter/material.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_colors.dart';
import 'blkwds_button.dart';

/// Fallback widget type
///
/// Defines the type of fallback widget to display
enum FallbackWidgetType {
  /// Error fallback
  error,

  /// Loading fallback
  loading,

  /// Empty state fallback
  empty,

  /// No data fallback
  noData,

  /// No connection fallback
  noConnection,
}

/// Fallback widget
///
/// A widget to display when a component cannot render its normal content
class FallbackWidget extends StatelessWidget {
  /// The type of fallback widget to display
  final FallbackWidgetType type;

  /// The message to display
  final String? message;

  /// The icon to display
  final IconData? icon;

  /// The action to perform when the retry button is pressed
  final VoidCallback? onRetry;

  /// The action to perform when the primary button is pressed
  final VoidCallback? onPrimaryAction;

  /// The label for the primary button
  final String? primaryActionLabel;

  /// The action to perform when the secondary button is pressed
  final VoidCallback? onSecondaryAction;

  /// The label for the secondary button
  final String? secondaryActionLabel;

  /// Whether to show a retry button
  final bool showRetry;

  /// Create a new fallback widget
  ///
  /// [type] is the type of fallback widget to display
  /// [message] is the message to display
  /// [icon] is the icon to display
  /// [onRetry] is the action to perform when the retry button is pressed
  /// [onPrimaryAction] is the action to perform when the primary button is pressed
  /// [primaryActionLabel] is the label for the primary button
  /// [onSecondaryAction] is the action to perform when the secondary button is pressed
  /// [secondaryActionLabel] is the label for the secondary button
  /// [showRetry] determines whether to show a retry button
  const FallbackWidget({
    super.key,
    required this.type,
    this.message,
    this.icon,
    this.onRetry,
    this.onPrimaryAction,
    this.primaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionLabel,
    this.showRetry = true,
  });

  /// Create an error fallback widget
  ///
  /// [message] is the error message to display
  /// [onRetry] is the action to perform when the retry button is pressed
  /// Returns a new fallback widget
  factory FallbackWidget.error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return FallbackWidget(
      type: FallbackWidgetType.error,
      message: message ?? 'An error occurred',
      icon: Icons.error_outline,
      onRetry: onRetry,
    );
  }

  /// Create a loading fallback widget
  ///
  /// [message] is the loading message to display
  /// Returns a new fallback widget
  factory FallbackWidget.loading({
    String? message,
  }) {
    return FallbackWidget(
      type: FallbackWidgetType.loading,
      message: message ?? 'Loading...',
      showRetry: false,
    );
  }

  /// Create an empty state fallback widget
  ///
  /// [message] is the empty state message to display
  /// [onPrimaryAction] is the action to perform when the primary button is pressed
  /// [primaryActionLabel] is the label for the primary button
  /// Returns a new fallback widget
  factory FallbackWidget.empty({
    String? message,
    IconData? icon,
    VoidCallback? onPrimaryAction,
    String? primaryActionLabel,
    VoidCallback? onSecondaryAction,
    String? secondaryActionLabel,
  }) {
    return FallbackWidget(
      type: FallbackWidgetType.empty,
      message: message ?? 'No items found',
      icon: icon ?? Icons.inbox_outlined,
      showRetry: false,
      onPrimaryAction: onPrimaryAction,
      primaryActionLabel: primaryActionLabel,
      onSecondaryAction: onSecondaryAction,
      secondaryActionLabel: secondaryActionLabel,
    );
  }

  /// Create a no data fallback widget
  ///
  /// [message] is the no data message to display
  /// [onRetry] is the action to perform when the retry button is pressed
  /// Returns a new fallback widget
  factory FallbackWidget.noData({
    String? message,
    IconData? icon,
    VoidCallback? onRetry,
    VoidCallback? onPrimaryAction,
    String? primaryActionLabel,
  }) {
    return FallbackWidget(
      type: FallbackWidgetType.noData,
      message: message ?? 'No data available',
      icon: icon ?? Icons.no_sim_outlined,
      onRetry: onRetry,
      onPrimaryAction: onPrimaryAction,
      primaryActionLabel: primaryActionLabel,
    );
  }

  /// Create a no connection fallback widget
  ///
  /// [message] is the no connection message to display
  /// [onRetry] is the action to perform when the retry button is pressed
  /// Returns a new fallback widget
  factory FallbackWidget.noConnection({
    String? message,
    VoidCallback? onRetry,
  }) {
    return FallbackWidget(
      type: FallbackWidgetType.noConnection,
      message: message ?? 'No internet connection',
      icon: Icons.wifi_off_outlined,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the appropriate color and icon based on the type
    final Color color = _getColor();
    final IconData iconToShow = icon ?? _getDefaultIcon();

    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 26), // 0.1 * 255 = 26
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        border: Border.all(color: color.withValues(alpha: 77)), // 0.3 * 255 = 77
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Show icon for all types except loading
          if (type != FallbackWidgetType.loading)
            Icon(
              iconToShow,
              color: color,
              size: BLKWDSConstants.iconSizeLarge,
            )
          else
            SizedBox(
              width: BLKWDSConstants.iconSizeLarge,
              height: BLKWDSConstants.iconSizeLarge,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 3,
              ),
            ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Message
          Text(
            message ?? _getDefaultMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BLKWDSColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Primary action button
              if (onPrimaryAction != null)
                BLKWDSButton(
                  label: primaryActionLabel ?? 'Action',
                  onPressed: onPrimaryAction!,
                  type: BLKWDSButtonType.primary,
                ),

              // Space between buttons
              if (onPrimaryAction != null && (showRetry && onRetry != null || onSecondaryAction != null))
                const SizedBox(width: BLKWDSConstants.spacingSmall),

              // Retry button
              if (showRetry && onRetry != null)
                BLKWDSButton(
                  label: 'Retry',
                  onPressed: onRetry!,
                  type: BLKWDSButtonType.secondary,
                ),

              // Secondary action button
              if (onSecondaryAction != null)
                BLKWDSButton(
                  label: secondaryActionLabel ?? 'Cancel',
                  onPressed: onSecondaryAction!,
                  type: BLKWDSButtonType.secondary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get the appropriate color based on the type
  ///
  /// Returns a color
  Color _getColor() {
    switch (type) {
      case FallbackWidgetType.error:
        return BLKWDSColors.errorRed;
      case FallbackWidgetType.loading:
        return BLKWDSColors.accentTeal;
      case FallbackWidgetType.empty:
        return BLKWDSColors.accentTeal;
      case FallbackWidgetType.noData:
        return BLKWDSColors.warningAmber;
      case FallbackWidgetType.noConnection:
        return BLKWDSColors.errorRed;
    }
  }

  /// Get the default icon based on the type
  ///
  /// Returns an icon
  IconData _getDefaultIcon() {
    switch (type) {
      case FallbackWidgetType.error:
        return Icons.error_outline;
      case FallbackWidgetType.loading:
        return Icons.hourglass_empty;
      case FallbackWidgetType.empty:
        return Icons.inbox_outlined;
      case FallbackWidgetType.noData:
        return Icons.no_sim_outlined;
      case FallbackWidgetType.noConnection:
        return Icons.wifi_off_outlined;
    }
  }

  /// Get the default message based on the type
  ///
  /// Returns a message
  String _getDefaultMessage() {
    switch (type) {
      case FallbackWidgetType.error:
        return 'An error occurred';
      case FallbackWidgetType.loading:
        return 'Loading...';
      case FallbackWidgetType.empty:
        return 'No items found';
      case FallbackWidgetType.noData:
        return 'No data available';
      case FallbackWidgetType.noConnection:
        return 'No internet connection';
    }
  }
}
