import 'package:flutter/material.dart';
import '../services/services.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_colors.dart';
import 'blkwds_button.dart';

/// Error boundary widget
///
/// A widget that catches errors in its child widget tree and displays a fallback UI
class ErrorBoundary extends StatefulWidget {
  /// The child widget that might throw errors
  final Widget child;

  /// The fallback widget to display when an error occurs
  final Widget? fallbackWidget;

  /// Callback when an error occurs
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Whether to track errors with the ErrorAnalyticsService
  final bool trackErrors;

  /// The source of the error for analytics
  final String errorSource;

  /// Create a new error boundary
  ///
  /// [child] is the child widget that might throw errors
  /// [fallbackWidget] is the fallback widget to display when an error occurs
  /// [onError] is a callback when an error occurs
  /// [trackErrors] determines whether to track errors with the ErrorAnalyticsService
  /// [errorSource] is the source of the error for analytics
  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackWidget,
    this.onError,
    this.trackErrors = true,
    this.errorSource = 'ui',
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  /// Whether an error has occurred
  bool _hasError = false;

  /// The error that occurred
  Object? _error;



  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // If an error occurred, display the fallback widget or a default error widget
      return widget.fallbackWidget ?? _buildDefaultErrorWidget(context);
    }

    // If no error occurred, wrap the child with an error handler
    return _ErrorHandler(
      child: widget.child,
      onError: (error, stackTrace) {
        // Set error state
        setState(() {
          _hasError = true;
          _error = error;
        });

        // Call onError callback if provided
        if (widget.onError != null) {
          widget.onError!(error, stackTrace);
        }

        // Track error if enabled
        if (widget.trackErrors) {
          ErrorAnalyticsService.trackError(
            error,
            stackTrace: stackTrace,
            source: widget.errorSource,
          );
        }

        // Log error
        LogService.error(
          'Error caught by ErrorBoundary (${widget.errorSource})',
          error,
          stackTrace,
        );
      },
    );
  }

  /// Build the default error widget
  ///
  /// [context] is the build context
  /// Returns a widget to display when an error occurs
  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: BLKWDSColors.errorRed.withValues(alpha: 26), // 0.1 * 255 = 26
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        border: Border.all(color: BLKWDSColors.errorRed.withValues(alpha: 77)), // 0.3 * 255 = 77
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: BLKWDSColors.errorRed,
                size: BLKWDSConstants.iconSizeMedium,
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: BLKWDSColors.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          Text(
            _error?.toString() ?? 'An unknown error occurred',
            style: TextStyle(
              color: BLKWDSColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
          BLKWDSButton(
            label: 'Retry',
            onPressed: () {
              // Reset error state
              setState(() {
                _hasError = false;
                _error = null;
              });
            },
            type: BLKWDSButtonType.secondary,
          ),
        ],
      ),
    );
  }
}

/// Error handler widget
///
/// A widget that catches errors in its child widget tree
class _ErrorHandler extends StatefulWidget {
  /// The child widget that might throw errors
  final Widget child;

  /// Callback when an error occurs
  final void Function(Object error, StackTrace stackTrace) onError;

  /// Create a new error handler
  ///
  /// [child] is the child widget that might throw errors
  /// [onError] is a callback when an error occurs
  const _ErrorHandler({
    required this.child,
    required this.onError,
  });

  @override
  State<_ErrorHandler> createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends State<_ErrorHandler> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Catch errors during didChangeDependencies
    try {
      super.didChangeDependencies();
    } catch (error, stackTrace) {
      widget.onError(error, stackTrace);
    }
  }

  @override
  void initState() {
    super.initState();
    // Catch errors during initState
    try {
      super.initState();
    } catch (error, stackTrace) {
      widget.onError(error, stackTrace);
    }
  }

  @override
  void didUpdateWidget(_ErrorHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Catch errors during didUpdateWidget
    try {
      super.didUpdateWidget(oldWidget);
    } catch (error, stackTrace) {
      widget.onError(error, stackTrace);
    }
  }

  @override
  void dispose() {
    // Catch errors during dispose
    try {
      super.dispose();
    } catch (error, stackTrace) {
      widget.onError(error, stackTrace);
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Catch errors during reassemble
    try {
      super.reassemble();
    } catch (error, stackTrace) {
      widget.onError(error, stackTrace);
    }
  }

  @override
  void deactivate() {
    // Catch errors during deactivate
    try {
      super.deactivate();
    } catch (error, stackTrace) {
      widget.onError(error, stackTrace);
    }
  }

  @override
  void activate() {
    // Catch errors during activate
    try {
      super.activate();
    } catch (error, stackTrace) {
      widget.onError(error, stackTrace);
    }
  }
}
