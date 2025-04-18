import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';

import '../../services/navigation_service.dart';
import '../../services/snackbar_service.dart';
import '../../theme/blkwds_animations.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';

import '../../widgets/blkwds_widgets.dart';
import '../../examples/error_handling_example.dart';
import '../../examples/recovery_example.dart';
import '../../examples/error_analytics_example.dart';
// Migration imports removed - migration is complete
import 'settings_controller.dart';
import '../../widgets/dialogs/data_seeding_dialog.dart';
import 'widgets/settings_section.dart';

/// SettingsScreen
/// Screen for configuring app settings and managing data
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controller
  final _controller = SettingsController();

  // State

  @override
  void initState() {
    super.initState();

    // Set the context for error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setContext(context);
    });

    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Theme mode is fixed to dark mode

  // Handle export data
  Future<void> _handleExportData() async {
    final filePath = await _controller.exportData();
    if (filePath != null) {
      _showSnackBar('Data exported to: $filePath');
    }
  }

  // Handle import data
  Future<void> _handleImportData() async {
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      title: 'Import Data',
      message: 'Importing data will replace all existing data. Are you sure you want to continue?',
    );

    if (confirmed != true) {
      return;
    }

    // Pick file
    final typeGroup = XTypeGroup(label: 'JSON', extensions: ['json']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      final success = await _controller.importData(file.path);
      if (success) {
        _showSnackBar('Data imported successfully');
      }
    }
  }

  // Handle export to CSV
  Future<void> _handleExportToCsv() async {
    final filePaths = await _controller.exportToCsv();
    if (filePaths != null && filePaths.isNotEmpty) {
      _showSnackBar('CSV files exported to: ${filePaths.first.split('/').last.split('_').first}');
    }
  }

  // Handle reset app data
  Future<void> _handleResetAppData() async {
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      title: 'Reset App Data',
      message: 'This will delete all data and reset the app to its initial state. This action cannot be undone. Are you sure you want to continue?',
      confirmText: 'Reset',
      isDestructive: true,
    );

    if (confirmed != true) {
      return;
    }

    final success = await _controller.resetAppData();
    if (success) {
      _showSnackBar('App data reset successfully');
    }
  }

  // Handle data seeder configuration
  void _handleDataSeederConfig() {
    showDialog(
      context: context,
      builder: (context) => const DataSeedingDialog(),
    );
  }



  // Show confirmation dialog
  Future<bool?> _showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BLKWDSEnhancedAlertDialog(
        title: title,
        content: message,
        secondaryActionText: cancelText,
        onSecondaryAction: () => Navigator.pop(context, false),
        primaryActionText: confirmText,
        onPrimaryAction: () => Navigator.pop(context, true),
        isPrimaryDestructive: isDestructive,
      ),
    );
  }

  // Show snackbar
  void _showSnackBar(String message) {
    SnackbarService.showInfo(context, message, duration: BLKWDSConstants.toastDuration);
  }

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: 'Settings',
      body: Stack(
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: _controller.isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return const Center(
                  child: BLKWDSLoadingSpinner(),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appearance section removed - app uses dark mode only

                    // Data management
                    SettingsSection(
                      title: 'Data Management',
                      children: [
                        // Export data
                        BLKWDSEnhancedButton(
                          label: 'Export Data (JSON)',
                          icon: Icons.upload_file,
                          type: BLKWDSEnhancedButtonType.secondary,
                          onPressed: _handleExportData,
                          width: double.infinity,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Import data
                        BLKWDSEnhancedButton(
                          label: 'Import Data (JSON)',
                          icon: Icons.download_rounded,
                          type: BLKWDSEnhancedButtonType.secondary,
                          onPressed: _handleImportData,
                          width: double.infinity,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Export to CSV
                        BLKWDSEnhancedButton(
                          label: 'Export to CSV',
                          icon: Icons.table_chart,
                          type: BLKWDSEnhancedButtonType.secondary,
                          onPressed: _handleExportToCsv,
                          width: double.infinity,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Data Seeder Configuration
                        BLKWDSEnhancedButton(
                          label: 'Data Seeder Configuration',
                          icon: Icons.data_array,
                          type: BLKWDSEnhancedButtonType.secondary,
                          onPressed: _handleDataSeederConfig,
                          width: double.infinity,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Reset app data
                        BLKWDSEnhancedButton(
                          label: 'Reset App Data',
                          icon: Icons.restore,
                          type: BLKWDSEnhancedButtonType.error,
                          onPressed: _handleResetAppData,
                          width: double.infinity,
                        ),
                      ],
                    ),

                    // Management
                    SettingsSection(
                      title: 'Management',
                      children: [
                        BLKWDSEnhancedListTile(
                          title: 'Member Management',
                          subtitle: 'Add, edit, and delete members',
                          trailing: const Icon(Icons.arrow_forward_ios),
                          leadingIcon: Icons.people,
                          onTap: () {
                            NavigationService.instance.navigateToMemberManagement();
                          },
                        ),
                        BLKWDSEnhancedListTile(
                          title: 'Project Management',
                          subtitle: 'Add, edit, and delete projects',
                          trailing: const Icon(Icons.arrow_forward_ios),
                          leadingIcon: Icons.business,
                          onTap: () {
                            NavigationService.instance.navigateToProjectManagement();
                          },
                        ),
                        BLKWDSEnhancedListTile(
                          title: 'Gear Management',
                          subtitle: 'Add, edit, and manage gear inventory',
                          trailing: const Icon(Icons.arrow_forward_ios),
                          leadingIcon: Icons.camera,
                          onTap: () {
                            NavigationService.instance.navigateToGearManagement();
                          },
                        ),
                        BLKWDSEnhancedListTile(
                          title: 'Database Integrity',
                          subtitle: 'Check and fix database integrity issues',
                          trailing: const Icon(Icons.arrow_forward_ios),
                          leadingIcon: Icons.storage,
                          onTap: () {
                            NavigationService.instance.navigateToDatabaseIntegrity();
                          },
                        ),
                        // Migration UI removed - migration is complete
                      ],
                    ),

                    // App information
                    SettingsSection(
                      title: 'About',
                      children: [
                        BLKWDSEnhancedListTile(
                          title: 'Version',
                          leadingIcon: Icons.info_outline,
                          trailing: Text(
                            '${_controller.appVersion} (${_controller.appBuildNumber})',
                            style: BLKWDSTypography.bodyMedium,
                          ),
                        ),
                        const Divider(),
                        BLKWDSEnhancedListTile(
                          title: 'Copyright',
                          leadingIcon: Icons.copyright,
                          trailing: Text(
                            _controller.appCopyright,
                            style: BLKWDSTypography.bodyMedium,
                          ),
                        ),
                        const Divider(),
                        BLKWDSEnhancedListTile(
                          title: 'App Configuration',
                          subtitle: 'View and edit application configuration',
                          trailing: const Icon(Icons.arrow_forward_ios),
                          leadingIcon: Icons.settings_applications,
                          onTap: () {
                            NavigationService.instance.navigateToAppConfig();
                          },
                        ),
                        const Divider(),
                        BLKWDSEnhancedListTile(
                          title: 'App Information',
                          subtitle: 'View detailed app information',
                          trailing: const Icon(Icons.arrow_forward_ios),
                          leadingIcon: Icons.info,
                          onTap: () {
                            NavigationService.instance.navigateToAppInfo();
                          },
                        ),
                        const Divider(),
                        BLKWDSEnhancedListTile(
                          title: 'Style Demo',
                          subtitle: 'View enhanced UI components',
                          trailing: const Icon(Icons.arrow_forward_ios),
                          leadingIcon: Icons.style,
                          onTap: () {
                            NavigationService.instance.navigateToStyleDemo();
                          },
                        ),
                      ],
                    ),

                    // Debug menu (only in debug mode)
                    if (kDebugMode) // Only show in debug mode
                      SettingsSection(
                        title: 'Debug',
                        children: [
                          BLKWDSEnhancedListTile(
                            title: 'Error Handling Example',
                            subtitle: 'Test the error handling system',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            leadingIcon: Icons.error_outline,
                            onTap: () {
                              NavigationService.instance.navigateTo(
                                const ErrorHandlingExample(),
                                transitionType: BLKWDSPageTransitionType.rightToLeft,
                              );
                            },
                          ),
                          const Divider(),
                          BLKWDSEnhancedListTile(
                            title: 'Recovery Mechanisms Example',
                            subtitle: 'Test the retry and recovery systems',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            leadingIcon: Icons.refresh,
                            onTap: () {
                              NavigationService.instance.navigateTo(
                                const RecoveryExample(),
                                transitionType: BLKWDSPageTransitionType.rightToLeft,
                              );
                            },
                          ),
                          const Divider(),
                          BLKWDSEnhancedListTile(
                            title: 'Error Analytics & Boundaries',
                            subtitle: 'Test error analytics and boundaries',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            leadingIcon: Icons.analytics,
                            onTap: () {
                              NavigationService.instance.navigateTo(
                                const ErrorAnalyticsExample(),
                                transitionType: BLKWDSPageTransitionType.rightToLeft,
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),


        ],
      ),
    );
  }
}
