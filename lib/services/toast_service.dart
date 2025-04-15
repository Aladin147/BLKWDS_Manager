import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Toast type
///
/// Determines the appearance of the toast
enum ToastType {
  /// Success toast (green)
  success,

  /// Error toast (red)
  error,

  /// Warning toast (amber)
  warning,

  /// Info toast (teal)
  info,
}

/// Toast position
///
/// Determines where the toast appears on the screen
enum ToastPosition {
  /// Top of the screen
  top,

  /// Bottom of the screen
  bottom,

  /// Center of the screen
  center,
}

/// Toast service
///
/// A service for displaying lightweight toast notifications
class ToastService {
  /// The overlay entry for the current toast
  static OverlayEntry? _overlayEntry;

  /// The timer for automatically dismissing the toast
  static Timer? _timer;

  /// Show a toast notification
  ///
  /// [context] is the build context
  /// [message] is the message to display
  /// [type] is the type of toast
  /// [position] is the position of the toast
  /// [duration] is how long the toast should be displayed
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.bottom,
    Duration? duration,
  }) {
    // Get the overlay state
    try {
      final overlay = Overlay.of(context);

      // Hide any existing toast
      hide();

      // Create a new overlay entry
      _overlayEntry = OverlayEntry(
        builder: (context) => _ToastWidget(
          message: message,
          type: type,
          position: position,
        ),
      );

      // Insert the overlay entry
      overlay.insert(_overlayEntry!);

      // Set up a timer to automatically dismiss the toast
      _timer = Timer(
        duration ?? BLKWDSConstants.toastDuration,
        () => hide(),
      );
    } catch (e) {
      debugPrint('Error showing toast: $e');
    }
  }

  /// Show a success toast
  ///
  /// [context] is the build context
  /// [message] is the message to display
  static void showSuccess(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: ToastType.success,
      position: position,
      duration: duration,
    );
  }

  /// Show an error toast
  ///
  /// [context] is the build context
  /// [message] is the message to display
  static void showError(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: ToastType.error,
      position: position,
      duration: duration,
    );
  }

  /// Show a warning toast
  ///
  /// [context] is the build context
  /// [message] is the message to display
  static void showWarning(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: ToastType.warning,
      position: position,
      duration: duration,
    );
  }

  /// Show an info toast
  ///
  /// [context] is the build context
  /// [message] is the message to display
  static void showInfo(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: ToastType.info,
      position: position,
      duration: duration,
    );
  }

  /// Hide the current toast
  static void hide() {
    _timer?.cancel();
    _timer = null;

    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Toast widget
///
/// A widget for displaying a toast notification
class _ToastWidget extends StatelessWidget {
  /// The message to display
  final String message;

  /// The type of toast
  final ToastType type;

  /// The position of the toast
  final ToastPosition position;

  /// Create a new toast widget
  ///
  /// [message] is the message to display
  /// [type] is the type of toast
  /// [position] is the position of the toast
  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;

    // Get the toast color based on the type
    final Color backgroundColor;
    final Color textColor;
    final IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = BLKWDSColors.successGreen.withValues(alpha: 230);
        textColor = BLKWDSColors.white;
        icon = Icons.check_circle_outline;
      case ToastType.error:
        backgroundColor = BLKWDSColors.errorRed.withValues(alpha: 230);
        textColor = BLKWDSColors.white;
        icon = Icons.error_outline;
      case ToastType.warning:
        backgroundColor = BLKWDSColors.warningAmber.withValues(alpha: 230);
        textColor = BLKWDSColors.white;
        icon = Icons.warning_amber_outlined;
      case ToastType.info:
        backgroundColor = BLKWDSColors.accentTeal.withValues(alpha: 230);
        textColor = BLKWDSColors.white;
        icon = Icons.info_outline;
    }

    // Get the toast position
    final Alignment alignment;
    final EdgeInsets padding;

    switch (position) {
      case ToastPosition.top:
        alignment = Alignment.topCenter;
        padding = EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + BLKWDSConstants.spacingLarge,
          left: BLKWDSConstants.spacingMedium,
          right: BLKWDSConstants.spacingMedium,
        );
      case ToastPosition.center:
        alignment = Alignment.center;
        padding = const EdgeInsets.symmetric(
          horizontal: BLKWDSConstants.spacingMedium,
        );
      case ToastPosition.bottom:
        alignment = Alignment.bottomCenter;
        padding = EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + BLKWDSConstants.spacingLarge,
          left: BLKWDSConstants.spacingMedium,
          right: BLKWDSConstants.spacingMedium,
        );
    }

    return Positioned(
      width: screenSize.width,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: screenSize.width * 0.8,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: BLKWDSConstants.spacingMedium,
                vertical: BLKWDSConstants.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: BLKWDSColors.deepBlack.withValues(alpha: 50),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: textColor,
                    size: BLKWDSConstants.iconSizeSmall,
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  Flexible(
                    child: Text(
                      message,
                      style: BLKWDSTypography.bodyMedium.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
