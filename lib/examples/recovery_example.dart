import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/services.dart';
import '../widgets/blkwds_widgets.dart';
import '../theme/blkwds_constants.dart';

/// Recovery Example
///
/// This example demonstrates how to use the recovery mechanisms
class RecoveryExample extends StatefulWidget {
  const RecoveryExample({super.key});

  @override
  State<RecoveryExample> createState() => _RecoveryExampleState();
}

class _RecoveryExampleState extends State<RecoveryExample> {
  String _status = 'Ready';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Mechanisms Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: ListView(
          children: [
            // Status display
            Container(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingSmall),
                  Text(_status),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: BLKWDSConstants.spacingSmall),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Retry examples
            _buildSection(
              'Retry Service',
              [
                _buildExampleButton(
                  'Retry with Success',
                  _retryWithSuccess,
                ),
                _buildExampleButton(
                  'Retry with Failure',
                  _retryWithFailure,
                ),
                _buildExampleButton(
                  'Retry with Exponential Backoff',
                  _retryWithExponentialBackoff,
                ),
              ],
            ),

            // Recovery examples
            _buildSection(
              'Recovery Service',
              [
                _buildExampleButton(
                  'Recovery with Fallback',
                  _recoveryWithFallback,
                ),
                _buildExampleButton(
                  'Recovery with Default Value',
                  _recoveryWithDefaultValue,
                ),
                _buildExampleButton(
                  'Recovery with User Choice',
                  _recoveryWithUserChoice,
                ),
              ],
            ),

            // Combined examples
            _buildSection(
              'Combined Examples',
              [
                _buildExampleButton(
                  'Retry then Fallback',
                  _retryThenFallback,
                ),
                _buildExampleButton(
                  'Complex Recovery Flow',
                  _complexRecoveryFlow,
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

  // Build an example button
  Widget _buildExampleButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: BLKWDSConstants.spacingSmall,
      ),
      child: BLKWDSButton(
        label: label,
        onPressed: _isLoading ? () {} : onPressed,
        type: BLKWDSButtonType.secondary,
        isFullWidth: true,
      ),
    );
  }

  // Simulate a network operation that might fail
  Future<String> _simulateNetworkOperation({
    required int attempts,
    required double successRate,
  }) async {
    // Update status
    setState(() {
      _status = 'Attempt $attempts: Simulating network operation...';
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Randomly succeed or fail based on success rate
    final random = Random();
    if (random.nextDouble() > successRate) {
      // Simulate failure
      setState(() {
        _status = 'Attempt $attempts: Network operation failed';
        _isLoading = false;
      });
      throw Exception('Simulated network failure: Connection failed');
    }

    // Simulate success
    setState(() {
      _status = 'Attempt $attempts: Network operation succeeded';
      _isLoading = false;
    });
    return 'Success data from network';
  }

  // Simulate a database operation that might fail
  Future<String> _simulateDatabaseOperation({
    required int attempts,
    required double successRate,
  }) async {
    // Update status
    setState(() {
      _status = 'Attempt $attempts: Simulating database operation...';
      _isLoading = true;
    });

    // Simulate database delay
    await Future.delayed(const Duration(seconds: 1));

    // Randomly succeed or fail based on success rate
    final random = Random();
    if (random.nextDouble() > successRate) {
      // Simulate failure
      setState(() {
        _status = 'Attempt $attempts: Database operation failed';
        _isLoading = false;
      });
      throw Exception('Simulated database failure: Database query failed');
    }

    // Simulate success
    setState(() {
      _status = 'Attempt $attempts: Database operation succeeded';
      _isLoading = false;
    });
    return 'Success data from database';
  }

  // Example: Retry with success
  Future<void> _retryWithSuccess() async {
    try {
      // Set up variables to track attempts
      int attempts = 0;

      // Use RetryService to retry an operation
      final result = await RetryService.retry(
        operation: () {
          attempts++;
          return _simulateNetworkOperation(
            attempts: attempts,
            // First attempt fails, second succeeds
            successRate: attempts > 1 ? 1.0 : 0.0,
          );
        },
        maxAttempts: 3,
        strategy: RetryStrategy.linear,
        initialDelay: const Duration(seconds: 1),
        onRetry: (attempt, error) {
          setState(() {
            _status = 'Retrying... Attempt $attempt/3';
          });
        },
      );

      // Update status with result
      setState(() {
        _status = 'Operation succeeded after $attempts attempts: $result';
      });
    } catch (e) {
      // Handle final failure
      setState(() {
        _status = 'Operation failed after multiple attempts: $e';
        _isLoading = false;
      });
    }
  }

  // Example: Retry with failure
  Future<void> _retryWithFailure() async {
    try {
      // Set up variables to track attempts
      int attempts = 0;

      // Use RetryService to retry an operation
      final result = await RetryService.retry(
        operation: () {
          attempts++;
          return _simulateNetworkOperation(
            attempts: attempts,
            // All attempts fail
            successRate: 0.0,
          );
        },
        maxAttempts: 3,
        strategy: RetryStrategy.linear,
        initialDelay: const Duration(seconds: 1),
        onRetry: (attempt, error) {
          setState(() {
            _status = 'Retrying... Attempt $attempt/3';
          });
        },
      );

      // This won't be reached if all attempts fail
      setState(() {
        _status = 'Operation succeeded after $attempts attempts: $result';
      });
    } catch (e) {
      // Handle final failure
      setState(() {
        _status = 'Operation failed after multiple attempts: $e';
        _isLoading = false;
      });

      // Show error dialog
      if (mounted) {
        ErrorDialogService.showErrorDialog(
          context,
          'Error',
          'Operation failed after multiple attempts. Please try again later.',
        );
      }
    }
  }

  // Example: Retry with exponential backoff
  Future<void> _retryWithExponentialBackoff() async {
    try {
      // Set up variables to track attempts
      int attempts = 0;

      // Use RetryService to retry an operation with exponential backoff
      final result = await RetryService.retry(
        operation: () {
          attempts++;
          return _simulateNetworkOperation(
            attempts: attempts,
            // Third attempt succeeds
            successRate: attempts > 2 ? 1.0 : 0.0,
          );
        },
        maxAttempts: 4,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        onRetry: (attempt, error) {
          final delay = Duration(milliseconds: 500 * (1 << (attempt - 1)));
          setState(() {
            _status = 'Retrying after $delay... Attempt $attempt/4';
          });
        },
      );

      // Update status with result
      setState(() {
        _status = 'Operation succeeded after $attempts attempts: $result';
      });
    } catch (e) {
      // Handle final failure
      setState(() {
        _status = 'Operation failed after multiple attempts: $e';
        _isLoading = false;
      });
    }
  }

  // Example: Recovery with fallback
  Future<void> _recoveryWithFallback() async {
    try {
      // Use RecoveryService to try an operation with a fallback
      final result = await RecoveryService.withFallback(
        operation: () async {
          // Primary operation (network)
          setState(() {
            _status = 'Trying primary operation (network)...';
            _isLoading = true;
          });

          // Simulate network delay
          await Future.delayed(const Duration(seconds: 1));

          // Always fail the primary operation
          setState(() {
            _status = 'Primary operation failed, trying fallback...';
          });
          throw Exception('Network operation failed');
        },
        fallback: () async {
          // Fallback operation (database)
          setState(() {
            _status = 'Executing fallback operation (database)...';
          });

          // Simulate database delay
          await Future.delayed(const Duration(seconds: 1));

          // Always succeed the fallback operation
          setState(() {
            _status = 'Fallback operation succeeded';
            _isLoading = false;
          });
          return 'Fallback data from database';
        },
      );

      // Update status with result
      setState(() {
        _status = 'Recovery succeeded with fallback: $result';
      });
    } catch (e) {
      // Handle final failure (both primary and fallback failed)
      setState(() {
        _status = 'Both primary and fallback operations failed: $e';
        _isLoading = false;
      });
    }
  }

  // Example: Recovery with default value
  Future<void> _recoveryWithDefaultValue() async {
    try {
      // Use RecoveryService to try an operation with a default value
      final result = await RecoveryService.withDefault(
        operation: () async {
          // Primary operation
          setState(() {
            _status = 'Trying operation...';
            _isLoading = true;
          });

          // Simulate delay
          await Future.delayed(const Duration(seconds: 1));

          // Always fail the operation
          setState(() {
            _status = 'Operation failed, using default value...';
          });
          throw Exception('Database operation failed');
        },
        defaultValue: 'Default cached data',
      );

      // Update status with result
      setState(() {
        _status = 'Recovery succeeded with default value: $result';
        _isLoading = false;
      });
    } catch (e) {
      // This shouldn't be reached when using withDefault
      setState(() {
        _status = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  // Example: Recovery with user choice
  Future<void> _recoveryWithUserChoice() async {
    try {
      // Use RecoveryService with recovery options
      final result = await RecoveryService.withRecovery(
        context: context,
        operation: () async {
          // Primary operation
          setState(() {
            _status = 'Trying operation...';
            _isLoading = true;
          });

          // Simulate delay
          await Future.delayed(const Duration(seconds: 1));

          // Always fail the operation
          setState(() {
            _status = 'Operation failed, showing recovery options...';
            _isLoading = false;
          });
          throw Exception('Network operation failed');
        },
        fallback: () async {
          // Fallback operation
          setState(() {
            _status = 'Executing fallback operation...';
            _isLoading = true;
          });

          // Simulate delay
          await Future.delayed(const Duration(seconds: 1));

          // Always succeed the fallback operation
          setState(() {
            _status = 'Fallback operation succeeded';
            _isLoading = false;
          });
          return 'Fallback data';
        },
        defaultValue: 'Default value if all else fails',
        showFeedback: true,
        recoveryStrategy: (error) {
          // Let the dialog decide the recovery action
          return RecoveryAction.fallback;
        },
      );

      // Update status with result
      setState(() {
        _status = 'Recovery succeeded: $result';
      });
    } catch (e) {
      // Handle final failure (user cancelled or all recovery options failed)
      setState(() {
        _status = 'Recovery failed or was cancelled: $e';
        _isLoading = false;
      });
    }
  }

  // Example: Retry then fallback
  Future<void> _retryThenFallback() async {
    try {
      // Set up variables to track attempts
      int attempts = 0;

      // First try with retry
      try {
        final result = await RetryService.retry(
          operation: () {
            attempts++;
            setState(() {
              _status = 'Retry attempt $attempts/3...';
              _isLoading = true;
            });

            // Simulate network operation that always fails
            return _simulateNetworkOperation(
              attempts: attempts,
              successRate: 0.0,
            );
          },
          maxAttempts: 3,
          strategy: RetryStrategy.linear,
          initialDelay: const Duration(seconds: 1),
        );

        // If retry succeeds (which it won't in this example)
        setState(() {
          _status = 'Retry succeeded: $result';
          _isLoading = false;
        });
      } catch (retryError) {
        // Retry failed, now try fallback
        setState(() {
          _status = 'Retry failed after $attempts attempts, trying fallback...';
        });

        // Use fallback
        final fallbackResult = await RecoveryService.withFallback(
          operation: () {
            // This will never be called because we're in the catch block
            throw Exception('This should never be called');
          },
          fallback: () async {
            // Fallback operation
            setState(() {
              _status = 'Executing fallback operation...';
            });

            // Simulate database operation that always succeeds
            return _simulateDatabaseOperation(
              attempts: 1,
              successRate: 1.0,
            );
          },
        );

        // Fallback succeeded
        setState(() {
          _status = 'Fallback succeeded: $fallbackResult';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle final failure (both retry and fallback failed)
      setState(() {
        _status = 'Both retry and fallback failed: $e';
        _isLoading = false;
      });

      // Show error dialog
      if (mounted) {
        ErrorDialogService.showErrorDialog(
          context,
          'Error',
          'All recovery attempts failed. Please try again later.',
        );
      }
    }
  }

  // Example: Complex recovery flow
  Future<void> _complexRecoveryFlow() async {
    try {
      // Set up variables
      int networkAttempts = 0;
      int databaseAttempts = 0;

      // Step 1: Try network with retry
      try {
        setState(() {
          _status = 'Step 1: Trying network operation with retry...';
          _isLoading = true;
        });

        final networkResult = await RetryService.retry(
          operation: () {
            networkAttempts++;
            return _simulateNetworkOperation(
              attempts: networkAttempts,
              // All network attempts fail
              successRate: 0.0,
            );
          },
          maxAttempts: 2,
          strategy: RetryStrategy.linear,
          initialDelay: const Duration(seconds: 1),
        );

        // If network succeeds (which it won't in this example)
        setState(() {
          _status = 'Network operation succeeded: $networkResult';
          _isLoading = false;
        });
        return;
      } catch (networkError) {
        // Step 2: Network failed, try database with retry
        setState(() {
          _status = 'Step 2: Network failed after $networkAttempts attempts, trying database...';
        });

        try {
          final databaseResult = await RetryService.retry(
            operation: () {
              databaseAttempts++;
              return _simulateDatabaseOperation(
                attempts: databaseAttempts,
                // Second database attempt succeeds
                successRate: databaseAttempts > 1 ? 1.0 : 0.0,
              );
            },
            maxAttempts: 3,
            strategy: RetryStrategy.exponential,
            initialDelay: const Duration(milliseconds: 500),
          );

          // Database succeeded
          setState(() {
            _status = 'Database operation succeeded after $databaseAttempts attempts: $databaseResult';
            _isLoading = false;
          });
          return;
        } catch (databaseError) {
          // Step 3: Both network and database failed, use cached data
          setState(() {
            _status = 'Step 3: Both network and database failed, using cached data...';
          });

          // Simulate delay for loading cached data
          await Future.delayed(const Duration(seconds: 1));

          // Use cached data
          setState(() {
            _status = 'Using cached data: Cached data from last successful operation';
            _isLoading = false;
          });

          // Show warning to user
          if (mounted) {
            SnackbarService.showWarning(
              context,
              'Using cached data. Some information may be outdated.',
            );
          }
        }
      }
    } catch (e) {
      // Handle unexpected errors
      setState(() {
        _status = 'Unexpected error in recovery flow: $e';
        _isLoading = false;
      });

      // Show error dialog
      if (mounted) {
        ErrorDialogService.showErrorDialog(
          context,
          'Error',
          'An unexpected error occurred: $e',
        );
      }
    }
  }
}
