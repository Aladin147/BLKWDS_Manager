import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import '../../models/models.dart';
import '../../services/navigation_service.dart';
import '../../theme/blkwds_animations.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';
import '../../examples/error_handling_example.dart';
import '../../examples/recovery_example.dart';
import '../../examples/error_analytics_example.dart';
import '../member_management/member_list_screen.dart';
import '../project_management/project_list_screen.dart';
import '../gear_management/gear_list_screen.dart';
// Migration imports removed - migration is complete
import 'settings_controller.dart';
import 'widgets/data_seeder_config_form.dart';
import 'widgets/settings_section.dart';
import 'app_config_screen.dart';

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
  bool _showDataSeederConfigForm = false;

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
    setState(() {
      _showDataSeederConfigForm = true;
    });
  }

  // Handle save data seeder configuration
  Future<void> _handleSaveDataSeederConfig(DataSeederConfig config) async {
    final success = await _controller.saveDataSeederConfig(config);
    if (success) {
      setState(() {
        _showDataSeederConfigForm = false;
      });
    }
  }

  // Handle reseed database
  Future<void> _handleReseedDatabase() async {
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      title: 'Reseed Database',
      message: 'This will delete all existing data and seed the database with new data based on your configuration. Are you sure you want to continue?',
      confirmText: 'Reseed',
      isDestructive: true,
    );

    if (confirmed != true) {
      return;
    }

    final success = await _controller.reseedDatabase();
    if (success) {
      setState(() {
        _showDataSeederConfigForm = false;
      });
    }
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
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          BLKWDSButton(
            label: cancelText,
            onPressed: () => Navigator.pop(context, false),
            type: BLKWDSButtonType.secondary,
            isSmall: true,
          ),
          BLKWDSButton(
            label: confirmText,
            onPressed: () => Navigator.pop(context, true),
            type: isDestructive ? BLKWDSButtonType.danger : BLKWDSButtonType.primary,
            isSmall: true,
          ),
        ],
      ),
    );
  }

  // Show snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: BLKWDSConstants.toastDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Stack(
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: _controller.isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
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
                        BLKWDSButton(
                          label: 'Export Data (JSON)',
                          icon: Icons.upload_file,
                          type: BLKWDSButtonType.secondary,
                          onPressed: _handleExportData,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Import data
                        BLKWDSButton(
                          label: 'Import Data (JSON)',
                          icon: Icons.download_rounded,
                          type: BLKWDSButtonType.secondary,
                          onPressed: _handleImportData,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Export to CSV
                        BLKWDSButton(
                          label: 'Export to CSV',
                          icon: Icons.table_chart,
                          type: BLKWDSButtonType.secondary,
                          onPressed: _handleExportToCsv,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Data Seeder Configuration
                        BLKWDSButton(
                          label: 'Data Seeder Configuration',
                          icon: Icons.data_array,
                          type: BLKWDSButtonType.secondary,
                          onPressed: _handleDataSeederConfig,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Reset app data
                        BLKWDSButton(
                          label: 'Reset App Data',
                          icon: Icons.restore,
                          type: BLKWDSButtonType.danger,
                          onPressed: _handleResetAppData,
                          isFullWidth: true,
                        ),
                      ],
                    ),

                    // Management
                    SettingsSection(
                      title: 'Management',
                      children: [
                        ListTile(
                          title: const Text('Member Management'),
                          subtitle: const Text('Add, edit, and delete members'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            NavigationService().navigateTo(
                              const MemberListScreen(),
                              transitionType: BLKWDSPageTransitionType.rightToLeft,
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Project Management'),
                          subtitle: const Text('Add, edit, and delete projects'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            NavigationService().navigateTo(
                              const ProjectListScreen(),
                              transitionType: BLKWDSPageTransitionType.rightToLeft,
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Gear Management'),
                          subtitle: const Text('Add, edit, and manage gear inventory'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            NavigationService().navigateTo(
                              const GearListScreen(),
                              transitionType: BLKWDSPageTransitionType.rightToLeft,
                            );
                          },
                        ),
                        // Migration UI removed - migration is complete
                      ],
                    ),

                    // App information
                    SettingsSection(
                      title: 'About',
                      children: [
                        ListTile(
                          title: const Text('Version'),
                          trailing: Text(
                            '${_controller.appVersion} (${_controller.appBuildNumber})',
                            style: BLKWDSTypography.bodyMedium,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Copyright'),
                          trailing: Text(
                            _controller.appCopyright,
                            style: BLKWDSTypography.bodyMedium,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('App Configuration'),
                          subtitle: const Text('View and edit application configuration'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            NavigationService().navigateTo(
                              const AppConfigScreen(),
                              transitionType: BLKWDSPageTransitionType.rightToLeft,
                            );
                          },
                        ),
                      ],
                    ),

                    // Debug menu (only in debug mode)
                    if (kDebugMode) // Only show in debug mode
                      SettingsSection(
                        title: 'Debug',
                        children: [
                          ListTile(
                            title: const Text('Error Handling Example'),
                            subtitle: const Text('Test the error handling system'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              NavigationService().navigateTo(
                                const ErrorHandlingExample(),
                                transitionType: BLKWDSPageTransitionType.rightToLeft,
                              );
                            },
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Recovery Mechanisms Example'),
                            subtitle: const Text('Test the retry and recovery systems'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              NavigationService().navigateTo(
                                const RecoveryExample(),
                                transitionType: BLKWDSPageTransitionType.rightToLeft,
                              );
                            },
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Error Analytics & Boundaries'),
                            subtitle: const Text('Test error analytics and boundaries'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              NavigationService().navigateTo(
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

          // Data seeder configuration form
          if (_showDataSeederConfigForm)
            ValueListenableBuilder<DataSeederConfig>(
              valueListenable: _controller.dataSeederConfig,
              builder: (context, config, _) {
                return DataSeederConfigForm(
                  config: config,
                  onSave: _handleSaveDataSeederConfig,
                  onCancel: () => setState(() => _showDataSeederConfigForm = false),
                  onReseed: _handleReseedDatabase,
                );
              },
            ),
        ],
      ),
    );
  }
}
