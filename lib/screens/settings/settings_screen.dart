import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';
import 'settings_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Handle theme mode change
  void _handleThemeModeChange(ThemeMode? mode) {
    if (mode != null) {
      _controller.setThemeMode(mode);
    }
  }

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
      body: ValueListenableBuilder<bool>(
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
                // Theme settings
                SettingsSection(
                  title: 'Appearance',
                  children: [
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: _controller.themeMode,
                      builder: (context, themeMode, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme Mode',
                              style: BLKWDSTypography.labelMedium,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingSmall),
                            SegmentedButton<ThemeMode>(
                              segments: const [
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.light,
                                  label: Text('Light'),
                                  icon: Icon(Icons.light_mode),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.dark,
                                  label: Text('Dark'),
                                  icon: Icon(Icons.dark_mode),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.system,
                                  label: Text('System'),
                                  icon: Icon(Icons.settings_suggest),
                                ),
                              ],
                              selected: {themeMode},
                              onSelectionChanged: (Set<ThemeMode> modes) {
                                _handleThemeModeChange(modes.first);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

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
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
