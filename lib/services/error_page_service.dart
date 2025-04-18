import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../widgets/blkwds_enhanced_button.dart';
import '../widgets/blkwds_enhanced_icon_container.dart';
import '../widgets/blkwds_enhanced_text.dart';
import 'navigation_service.dart';
import 'error_type.dart';

/// ErrorPageService
///
/// A service for displaying full-page error screens
class ErrorPageService {
  static final NavigationService _navigationService = NavigationService();

  /// Show a full-page error screen
  ///
  /// [context] is the build context
  /// [title] is the error title
  /// [message] is the error message
  /// [onRetry] is the callback when the retry button is pressed
  /// [showRetryButton] is whether to show a retry button
  /// [showHomeButton] is whether to show a home button
  static Widget buildErrorPage({
    required BuildContext context,
    String title = 'Something went wrong',
    required String message,
    VoidCallback? onRetry,
    bool showRetryButton = true,
    bool showHomeButton = true,
  }) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.contentPaddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BLKWDSEnhancedIconContainer(
                icon: Icons.error_outline,
                size: BLKWDSEnhancedIconContainerSize.large,
                backgroundColor: BLKWDSColors.errorRed.withValues(alpha: 20),
                iconColor: BLKWDSColors.errorRed,
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              BLKWDSEnhancedText.headingMedium(
                title,
                color: BLKWDSColors.errorRed,
              ),
              const SizedBox(height: BLKWDSConstants.spacingXSmall),
              BLKWDSEnhancedText.bodyMedium(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              if (showRetryButton && onRetry != null)
                BLKWDSEnhancedButton(
                  label: 'Retry',
                  onPressed: onRetry,
                  type: BLKWDSEnhancedButtonType.primary,
                  icon: Icons.refresh,
                ),
              if (showRetryButton && onRetry != null && showHomeButton)
                const SizedBox(height: BLKWDSConstants.spacingSmall),
              if (showHomeButton)
                BLKWDSEnhancedButton(
                  label: 'Return to Dashboard',
                  onPressed: () {
                    _navigationService.navigateToDashboard(clearStack: true);
                  },
                  type: showRetryButton && onRetry != null
                      ? BLKWDSEnhancedButtonType.secondary
                      : BLKWDSEnhancedButtonType.primary,
                  icon: Icons.home,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to a full-page error screen
  ///
  /// [context] is the build context
  /// [title] is the error title
  /// [message] is the error message
  /// [onRetry] is the callback when the retry button is pressed
  /// [showRetryButton] is whether to show a retry button
  /// [showHomeButton] is whether to show a home button
  static void navigateToErrorPage({
    required BuildContext context,
    String title = 'Something went wrong',
    required String message,
    VoidCallback? onRetry,
    bool showRetryButton = true,
    bool showHomeButton = true,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => buildErrorPage(
          context: context,
          title: title,
          message: message,
          onRetry: onRetry,
          showRetryButton: showRetryButton,
          showHomeButton: showHomeButton,
        ),
      ),
    );
  }

  /// Get an appropriate error title based on error type
  ///
  /// [type] is the error type
  /// Returns a user-friendly error title
  static String getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Network Error';
      case ErrorType.database:
        return 'Database Error';
      case ErrorType.auth:
        return 'Authentication Error';
      case ErrorType.permission:
        return 'Permission Error';
      case ErrorType.fileSystem:
        return 'File System Error';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.validation:
        return 'Validation Error';
      case ErrorType.input:
        return 'Input Error';
      case ErrorType.format:
        return 'Format Error';
      case ErrorType.state:
        return 'State Error';
      case ErrorType.configuration:
        return 'Configuration Error';
      case ErrorType.conflict:
        return 'Conflict Error';
      case ErrorType.unknown:
        return 'Something went wrong';
    }
  }
}
