import 'dart:math';
import 'package:flutter/material.dart';
import '../services/services.dart';
import '../widgets/blkwds_widgets.dart';
import '../theme/blkwds_constants.dart';

/// Error Analytics Example
///
/// This example demonstrates how to use error analytics and error boundaries
class ErrorAnalyticsExample extends StatefulWidget {
  const ErrorAnalyticsExample({super.key});

  @override
  State<ErrorAnalyticsExample> createState() => _ErrorAnalyticsExampleState();
}

class _ErrorAnalyticsExampleState extends State<ErrorAnalyticsExample> {
  // Error analytics data
  Map<ErrorType, int> _errorCounts = {};
  Map<String, int> _errorSourceCounts = {};
  List<ErrorRecord> _recentErrors = [];

  @override
  void initState() {
    super.initState();
    _loadErrorAnalytics();
  }

  /// Load error analytics data
  Future<void> _loadErrorAnalytics() async {
    // Initialize error analytics service if not already initialized
    await ErrorAnalyticsService.initialize();

    // Get error counts and recent errors
    setState(() {
      _errorCounts = ErrorAnalyticsService.getErrorCountsByType();
      _errorSourceCounts = ErrorAnalyticsService.getErrorCountsBySource();
      _recentErrors = ErrorAnalyticsService.getRecentErrors(limit: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Analytics & Boundaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadErrorAnalytics,
            tooltip: 'Refresh Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await ErrorAnalyticsService.clearErrorLog();
              _loadErrorAnalytics();
            },
            tooltip: 'Clear Error Log',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: ListView(
          children: [
            // Error Boundaries section
            _buildSection(
              'Error Boundaries',
              [
                _buildExampleButton(
                  'Trigger UI Error',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const _ErrorBoundaryDemoScreen(),
                      ),
                    );
                  },
                ),
                _buildExampleButton(
                  'Trigger Error in ErrorBoundary',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const _ErrorBoundaryWithErrorScreen(),
                      ),
                    );
                  },
                ),
                _buildExampleButton(
                  'Show Fallback Widgets',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const _FallbackWidgetDemoScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Error Analytics section
            _buildSection(
              'Error Analytics',
              [
                _buildExampleButton(
                  'Track Random Error',
                  _trackRandomError,
                ),
                _buildExampleButton(
                  'Track Error with Metadata',
                  () => _trackErrorWithMetadata(),
                ),
                _buildExampleButton(
                  'Export Error Log',
                  _exportErrorLog,
                ),
              ],
            ),

            // Error Analytics Data section
            _buildSection(
              'Error Analytics Data',
              [
                // Error counts by type
                _buildSubsection(
                  'Error Counts by Type',
                  _errorCounts.isEmpty
                      ? [const Text('No errors tracked yet')]
                      : _errorCounts.entries.map((entry) {
                          return _buildErrorCountItem(
                            entry.key.toString().split('.').last,
                            entry.value,
                          );
                        }).toList(),
                ),

                // Error counts by source
                _buildSubsection(
                  'Error Counts by Source',
                  _errorSourceCounts.isEmpty
                      ? [const Text('No errors tracked yet')]
                      : _errorSourceCounts.entries.map((entry) {
                          return _buildErrorCountItem(
                            entry.key,
                            entry.value,
                          );
                        }).toList(),
                ),

                // Recent errors
                _buildSubsection(
                  'Recent Errors',
                  _recentErrors.isEmpty
                      ? [const Text('No errors tracked yet')]
                      : _recentErrors.map((error) {
                          return _buildRecentErrorItem(error);
                        }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build a section with a title and a list of widgets
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: BLKWDSConstants.spacingMedium,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  // Build a subsection with a title and a list of widgets
  Widget _buildSubsection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: BLKWDSConstants.spacingSmall,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: BLKWDSConstants.spacingMedium),
      ],
    );
  }

  // Build an example button
  Widget _buildExampleButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: BLKWDSConstants.spacingSmall,
      ),
      child: BLKWDSButton(
        label: label,
        onPressed: onPressed,
        type: BLKWDSButtonType.secondary,
        isFullWidth: true,
      ),
    );
  }

  // Build an error count item
  Widget _buildErrorCountItem(String name, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: BLKWDSConstants.spacingExtraSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BLKWDSConstants.spacingSmall,
              vertical: BLKWDSConstants.spacingExtraSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadiusSmall),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a recent error item
  Widget _buildRecentErrorItem(ErrorRecord error) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: BLKWDSConstants.spacingSmall,
      ),
      child: Container(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  error.errorType.toString().split('.').last,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTimestamp(error.timestamp),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingExtraSmall),
            Text(
              error.message,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: BLKWDSConstants.spacingExtraSmall),
            Text(
              'Source: ${error.source}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
            if (error.metadata != null) ...[
              const SizedBox(height: BLKWDSConstants.spacingExtraSmall),
              Text(
                'Metadata: ${error.metadata}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Track a random error
  Future<void> _trackRandomError() async {
    final random = Random();
    final errorTypes = ErrorType.values;
    final errorType = errorTypes[random.nextInt(errorTypes.length)];
    final errorMessage = 'Random ${errorType.toString().split('.').last} error';

    try {
      // Simulate an error
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Track the error
      await ErrorAnalyticsService.trackError(
        e,
        stackTrace: stackTrace,
        source: 'ErrorAnalyticsExample',
      );

      // Show success message
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          'Error tracked: $errorMessage',
        );
      }

      // Refresh analytics data
      _loadErrorAnalytics();
    }
  }

  // Track an error with metadata
  Future<void> _trackErrorWithMetadata() async {
    try {
      // Simulate an error
      throw ValidationException(
        'Invalid input',
        field: 'username',
      );
    } catch (e, stackTrace) {
      // Track the error with metadata
      await ErrorAnalyticsService.trackError(
        e,
        stackTrace: stackTrace,
        source: 'ErrorAnalyticsExample',
        metadata: {
          'screen': 'ErrorAnalyticsExample',
          'action': 'trackErrorWithMetadata',
          'timestamp': DateTime.now().toIso8601String(),
          'user_id': 'test_user',
        },
      );

      // Show success message
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          'Error with metadata tracked',
        );
      }

      // Refresh analytics data
      _loadErrorAnalytics();
    }
  }

  // Export error log
  void _exportErrorLog() {
    final errorLog = ErrorAnalyticsService.exportErrorLogToJson();

    // Show dialog with error log
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Log'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              errorLog,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Error Boundary Demo Screen
///
/// This screen demonstrates how to use error boundaries
class _ErrorBoundaryDemoScreen extends StatefulWidget {
  const _ErrorBoundaryDemoScreen();

  @override
  State<_ErrorBoundaryDemoScreen> createState() => _ErrorBoundaryDemoScreenState();
}

class _ErrorBoundaryDemoScreenState extends State<_ErrorBoundaryDemoScreen> {
  bool _shouldThrowError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Boundary Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This screen demonstrates how to use error boundaries to catch errors in UI components.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            BLKWDSButton(
              label: 'Toggle Error',
              onPressed: () {
                setState(() {
                  _shouldThrowError = !_shouldThrowError;
                });
              },
              type: BLKWDSButtonType.primary,
              isFullWidth: true,
            ),
            const SizedBox(height: BLKWDSConstants.spacingLarge),
            const Text(
              'Component with Error Boundary:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            // Wrap the component with an error boundary
            ErrorBoundary(
              errorSource: 'ErrorBoundaryDemo',
              child: _ErrorProneWidget(shouldThrowError: _shouldThrowError),
            ),
            const SizedBox(height: BLKWDSConstants.spacingLarge),
            const Text(
              'Component without Error Boundary:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            // Component without error boundary
            _ErrorProneWidget(shouldThrowError: _shouldThrowError),
          ],
        ),
      ),
    );
  }
}

/// Error Prone Widget
///
/// This widget throws an error when shouldThrowError is true
class _ErrorProneWidget extends StatelessWidget {
  final bool shouldThrowError;

  const _ErrorProneWidget({
    required this.shouldThrowError,
  });

  @override
  Widget build(BuildContext context) {
    // Throw an error if shouldThrowError is true
    if (shouldThrowError) {
      throw Exception('This is a test error');
    }

    // Normal widget
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: const Text(
        'This widget is working correctly',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

/// Error Boundary With Error Screen
///
/// This screen demonstrates an error in the error boundary itself
class _ErrorBoundaryWithErrorScreen extends StatelessWidget {
  const _ErrorBoundaryWithErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error in ErrorBoundary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This screen demonstrates what happens when there is an error in the error boundary itself.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            // Error boundary with a custom fallback widget that throws an error
            ErrorBoundary(
              errorSource: 'ErrorBoundaryWithError',
              fallbackWidget: const _ErrorProneFallbackWidget(),
              child: const _AlwaysErrorWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Always Error Widget
///
/// This widget always throws an error
class _AlwaysErrorWidget extends StatelessWidget {
  const _AlwaysErrorWidget();

  @override
  Widget build(BuildContext context) {
    // Always throw an error
    throw Exception('This widget always throws an error');
  }
}

/// Error Prone Fallback Widget
///
/// This fallback widget throws an error
class _ErrorProneFallbackWidget extends StatelessWidget {
  const _ErrorProneFallbackWidget();

  @override
  Widget build(BuildContext context) {
    // Throw an error in the fallback widget
    throw Exception('Error in fallback widget');
  }
}

/// Fallback Widget Demo Screen
///
/// This screen demonstrates the different types of fallback widgets
class _FallbackWidgetDemoScreen extends StatelessWidget {
  const _FallbackWidgetDemoScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fallback Widgets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: ListView(
          children: [
            const Text(
              'This screen demonstrates the different types of fallback widgets.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            // Error fallback
            _buildFallbackSection(
              'Error Fallback',
              FallbackWidget.error(
                message: 'An error occurred while loading data',
                onRetry: () {
                  SnackbarService.showInfo(
                    context,
                    'Retrying...',
                  );
                },
              ),
            ),
            // Loading fallback
            _buildFallbackSection(
              'Loading Fallback',
              FallbackWidget.loading(
                message: 'Loading data...',
              ),
            ),
            // Empty state fallback
            _buildFallbackSection(
              'Empty State Fallback',
              FallbackWidget.empty(
                message: 'No items found',
                onPrimaryAction: () {
                  SnackbarService.showInfo(
                    context,
                    'Adding new item...',
                  );
                },
                primaryActionLabel: 'Add Item',
              ),
            ),
            // No data fallback
            _buildFallbackSection(
              'No Data Fallback',
              FallbackWidget.noData(
                message: 'No data available',
                onRetry: () {
                  SnackbarService.showInfo(
                    context,
                    'Refreshing data...',
                  );
                },
              ),
            ),
            // No connection fallback
            _buildFallbackSection(
              'No Connection Fallback',
              FallbackWidget.noConnection(
                message: 'No internet connection',
                onRetry: () {
                  SnackbarService.showInfo(
                    context,
                    'Checking connection...',
                  );
                },
              ),
            ),
            // Custom fallback
            _buildFallbackSection(
              'Custom Fallback',
              FallbackWidget(
                type: FallbackWidgetType.error,
                message: 'Custom fallback widget',
                icon: Icons.warning_amber_outlined,
                onRetry: () {
                  SnackbarService.showInfo(
                    context,
                    'Retrying...',
                  );
                },
                onPrimaryAction: () {
                  SnackbarService.showInfo(
                    context,
                    'Primary action...',
                  );
                },
                primaryActionLabel: 'Primary',
                onSecondaryAction: () {
                  SnackbarService.showInfo(
                    context,
                    'Secondary action...',
                  );
                },
                secondaryActionLabel: 'Secondary',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a fallback section
  Widget _buildFallbackSection(String title, Widget fallbackWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        fallbackWidget,
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        const Divider(),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
      ],
    );
  }
}
