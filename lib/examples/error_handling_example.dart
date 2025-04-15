import 'package:flutter/material.dart';
import '../services/services.dart';
import '../widgets/blkwds_widgets.dart';
import '../theme/blkwds_constants.dart';

/// Error Handling Example
///
/// This example demonstrates how to use the error handling system
class ErrorHandlingExample extends StatelessWidget {
  const ErrorHandlingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: ListView(
          children: [
            // Toast notifications
            _buildSection(
              'Toast Notifications',
              [
                _buildExampleButton(
                  'Show Error Toast',
                  () => ToastService.showError(
                    context,
                    'This is an error toast message',
                  ),
                ),
                _buildExampleButton(
                  'Show Success Toast',
                  () => ToastService.showSuccess(
                    context,
                    'Operation completed successfully',
                  ),
                ),
                _buildExampleButton(
                  'Show Warning Toast',
                  () => ToastService.showWarning(
                    context,
                    'This is a warning toast message',
                  ),
                ),
                _buildExampleButton(
                  'Show Info Toast',
                  () => ToastService.showInfo(
                    context,
                    'This is an informational toast message',
                  ),
                ),
                _buildExampleButton(
                  'Show Toast at Top',
                  () => ToastService.showInfo(
                    context,
                    'This toast appears at the top',
                    position: ToastPosition.top,
                  ),
                ),
                _buildExampleButton(
                  'Show Toast in Center',
                  () => ToastService.showInfo(
                    context,
                    'This toast appears in the center',
                    position: ToastPosition.center,
                  ),
                ),
              ],
            ),

            // Snackbar notifications
            _buildSection(
              'Snackbar Notifications',
              [
                _buildExampleButton(
                  'Show Error Snackbar',
                  () => SnackbarService.showError(
                    context,
                    'This is an error message',
                  ),
                ),
                _buildExampleButton(
                  'Show Success Snackbar',
                  () => SnackbarService.showSuccess(
                    context,
                    'Operation completed successfully',
                  ),
                ),
                _buildExampleButton(
                  'Show Warning Snackbar',
                  () => SnackbarService.showWarning(
                    context,
                    'This is a warning message',
                  ),
                ),
                _buildExampleButton(
                  'Show Info Snackbar',
                  () => SnackbarService.showInfo(
                    context,
                    'This is an informational message',
                  ),
                ),
              ],
            ),

            // Error dialogs
            _buildSection(
              'Error Dialogs',
              [
                _buildExampleButton(
                  'Show Error Dialog',
                  () => ErrorService.showErrorDialog(
                    context,
                    'This is an error message',
                  ),
                ),
                _buildExampleButton(
                  'Show Warning Dialog',
                  () => ErrorService.showWarningDialog(
                    context,
                    'Warning',
                    'This is a warning message',
                  ),
                ),
                _buildExampleButton(
                  'Show Custom Error Dialog',
                  () => ErrorService.showCustomErrorDialog(
                    context,
                    'Custom Error',
                    'This is a custom error message',
                    actions: [
                      ErrorAction.retry,
                      ErrorAction.cancel,
                    ],
                  ),
                ),
              ],
            ),

            // Error banners
            _buildSection(
              'Error Banners',
              [
                _buildExampleButton(
                  'Show Error Banner',
                  () => BannerService.showError(
                    'This is an error banner message',
                    onRetry: () {
                      SnackbarService.showInfo(
                        context,
                        'Retry action triggered',
                      );
                    },
                    onDismiss: () {
                      BannerService.hideBanner();
                      SnackbarService.showInfo(
                        context,
                        'Banner dismissed',
                      );
                    },
                  ),
                ),
                _buildExampleButton(
                  'Show Warning Banner',
                  () => BannerService.showWarning(
                    'This is a warning banner message',
                    onRetry: () {
                      SnackbarService.showInfo(
                        context,
                        'Retry action triggered',
                      );
                    },
                    onDismiss: () {
                      BannerService.hideBanner();
                      SnackbarService.showInfo(
                        context,
                        'Banner dismissed',
                      );
                    },
                  ),
                ),
                _buildExampleButton(
                  'Show Info Banner',
                  () => BannerService.showInfo(
                    'This is an info banner message',
                    onDismiss: () {
                      BannerService.hideBanner();
                      SnackbarService.showInfo(
                        context,
                        'Banner dismissed',
                      );
                    },
                  ),
                ),
                _buildExampleButton(
                  'Hide Banner',
                  () => BannerService.hideBanner(),
                ),
              ],
            ),

            // Exception handling
            _buildSection(
              'Exception Handling',
              [
                _buildExampleButton(
                  'Handle Database Exception',
                  () {
                    try {
                      throw DatabaseException(
                        'Failed to connect to database',
                        originalError: Exception('Connection refused'),
                      );
                    } catch (e) {
                      ContextualErrorHandler.handleError(
                        context,
                        e,
                      );
                    }
                  },
                ),
                _buildExampleButton(
                  'Handle Validation Exception',
                  () {
                    try {
                      throw ValidationException(
                        'Invalid email address',
                        field: 'email',
                      );
                    } catch (e) {
                      ContextualErrorHandler.handleError(
                        context,
                        e,
                      );
                    }
                  },
                ),
                _buildExampleButton(
                  'Handle Not Found Exception',
                  () {
                    try {
                      throw NotFoundException(
                        'Gear not found',
                        resource: 'Gear',
                        identifier: 123,
                      );
                    } catch (e) {
                      ContextualErrorHandler.handleError(
                        context,
                        e,
                      );
                    }
                  },
                ),
              ],
            ),

            // Form validation
            _buildSection(
              'Form Validation',
              [
                _buildExampleButton(
                  'Validate Form',
                  () {
                    final formData = {
                      'name': '',
                      'email': 'invalid-email',
                      'password': '123',
                    };

                    final rules = {
                      'name': [
                        RequiredRule(
                          errorMessage: 'Name is required',
                        ),
                      ],
                      'email': [
                        RequiredRule(),
                        EmailRule(),
                      ],
                      'password': [
                        RequiredRule(),
                        MinLengthRule(
                          minLength: 8,
                          errorMessage: 'Password must be at least 8 characters',
                        ),
                      ],
                    };

                    final errors = FormErrorHandler.validateForm(formData, rules);

                    if (errors.isNotEmpty) {
                      final firstField = errors.keys.first;
                      final firstError = errors[firstField]!;

                      SnackbarService.showError(
                        context,
                        '$firstField: $firstError',
                      );
                    } else {
                      SnackbarService.showSuccess(
                        context,
                        'Form validation passed',
                      );
                    }
                  },
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
        onPressed: onPressed,
        type: BLKWDSButtonType.secondary,
        isFullWidth: true,
      ),
    );
  }
}
