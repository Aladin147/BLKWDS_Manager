import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/app_config_service.dart';
import '../../services/log_service.dart';
import '../../services/error_service.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';

/// AppConfigScreen
/// Screen for viewing and editing the application configuration
class AppConfigScreen extends StatefulWidget {
  /// Constructor
  const AppConfigScreen({super.key});

  @override
  State<AppConfigScreen> createState() => _AppConfigScreenState();
}

class _AppConfigScreenState extends State<AppConfigScreen> {
  late AppConfig _config;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _config = AppConfigService.config;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Configuration',
            onPressed: _saveConfig,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to Defaults',
            onPressed: _resetConfig,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildConfigForm(),
    );
  }

  Widget _buildConfigForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null)
            BLKWDSErrorBanner(
              message: _errorMessage!,
              onDismiss: () => setState(() => _errorMessage = null),
            ),
          if (_successMessage != null)
            Container(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingLarge),
              decoration: BoxDecoration(
                color: BLKWDSColors.successGreen.withValues(alpha: 26), // 0.1 * 255 = 26
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                border: Border.all(color: BLKWDSColors.successGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: BLKWDSColors.successGreen),
                  const SizedBox(width: BLKWDSConstants.spacingMedium),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: BLKWDSColors.successGreen),
                    onPressed: () => setState(() => _successMessage = null),
                  ),
                ],
              ),
            ),
          _buildAppInfoSection(),
          const Divider(),
          _buildDatabaseSection(),
          const Divider(),
          _buildStudioSection(),
          const Divider(),
          _buildUISection(),
          const Divider(),
          _buildDataSeederSection(),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('App Information', style: BLKWDSTypography.titleLarge),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        _buildTextField(
          label: 'App Name',
          value: _config.appInfo.appName,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(
                appInfo: _config.appInfo.copyWith(appName: value),
              );
            });
          },
        ),
        _buildTextField(
          label: 'App Version',
          value: _config.appInfo.appVersion,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(
                appInfo: _config.appInfo.copyWith(appVersion: value),
              );
            });
          },
        ),
        _buildTextField(
          label: 'App Build Number',
          value: _config.appInfo.appBuildNumber,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(
                appInfo: _config.appInfo.copyWith(appBuildNumber: value),
              );
            });
          },
        ),
        _buildTextField(
          label: 'App Copyright',
          value: _config.appInfo.appCopyright,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(
                appInfo: _config.appInfo.copyWith(appCopyright: value),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildDatabaseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Database Configuration', style: BLKWDSTypography.titleLarge),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        _buildTextField(
          label: 'Database Name',
          value: _config.database.databaseName,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(
                database: _config.database.copyWith(databaseName: value),
              );
            });
          },
        ),
        _buildNumberField(
          label: 'Database Version',
          value: _config.database.databaseVersion.toString(),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null) {
              setState(() {
                _config = _config.copyWith(
                  database: _config.database.copyWith(databaseVersion: intValue),
                );
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildStudioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Studio Configuration', style: BLKWDSTypography.titleLarge),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        _buildTimeField(
          label: 'Opening Time',
          value: _config.studio.openingTime,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(
                studio: _config.studio.copyWith(openingTime: value),
              );
            });
          },
        ),
        _buildTimeField(
          label: 'Closing Time',
          value: _config.studio.closingTime,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(
                studio: _config.studio.copyWith(closingTime: value),
              );
            });
          },
        ),
        _buildNumberField(
          label: 'Minimum Booking Duration (minutes)',
          value: _config.studio.minBookingDuration.toString(),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null) {
              setState(() {
                _config = _config.copyWith(
                  studio: _config.studio.copyWith(minBookingDuration: intValue),
                );
              });
            }
          },
        ),
        _buildNumberField(
          label: 'Maximum Booking Duration (minutes)',
          value: _config.studio.maxBookingDuration.toString(),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null) {
              setState(() {
                _config = _config.copyWith(
                  studio: _config.studio.copyWith(maxBookingDuration: intValue),
                );
              });
            }
          },
        ),
        _buildSwitchField(
          label: 'Allow Overlapping Bookings',
          value: _config.studio.allowOverlappingBookings,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(
                studio: _config.studio.copyWith(allowOverlappingBookings: value),
              );
            });
          },
        ),
        _buildSwitchField(
          label: 'Enforce Studio Hours',
          value: _config.studio.enforceStudioHours,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(
                studio: _config.studio.copyWith(enforceStudioHours: value),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildUISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('UI Configuration', style: BLKWDSTypography.titleLarge),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        _buildDropdownField<ThemeMode>(
          label: 'Theme Mode',
          value: _config.ui.themeMode,
          items: ThemeMode.values,
          itemBuilder: (mode) => Text(mode.toString().split('.').last),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _config = _config.copyWith(
                  ui: _config.ui.copyWith(themeMode: value),
                );
              });
            }
          },
        ),
        _buildNumberField(
          label: 'Snackbar Duration (seconds)',
          value: _config.ui.snackbarDuration.toString(),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null) {
              setState(() {
                _config = _config.copyWith(
                  ui: _config.ui.copyWith(snackbarDuration: intValue),
                );
              });
            }
          },
        ),
        _buildNumberField(
          label: 'Animation Duration (milliseconds)',
          value: _config.ui.animationDuration.toString(),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null) {
              setState(() {
                _config = _config.copyWith(
                  ui: _config.ui.copyWith(animationDuration: intValue),
                );
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDataSeederSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data Seeder Defaults', style: BLKWDSTypography.titleLarge),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        _buildNumberField(
          label: 'Minimal Member Count',
          value: _config.dataSeeder.minimalMemberCount.toString(),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null) {
              setState(() {
                _config = _config.copyWith(
                  dataSeeder: _config.dataSeeder.copyWith(minimalMemberCount: intValue),
                );
              });
            }
          },
        ),
        _buildNumberField(
          label: 'Standard Member Count',
          value: _config.dataSeeder.standardMemberCount.toString(),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null) {
              setState(() {
                _config = _config.copyWith(
                  dataSeeder: _config.dataSeeder.copyWith(standardMemberCount: intValue),
                );
              });
            }
          },
        ),
        _buildNumberField(
          label: 'Comprehensive Member Count',
          value: _config.dataSeeder.comprehensiveMemberCount.toString(),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null) {
              setState(() {
                _config = _config.copyWith(
                  dataSeeder: _config.dataSeeder.copyWith(comprehensiveMemberCount: intValue),
                );
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay value,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
      child: InkWell(
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: value,
          );
          if (time != null) {
            onChanged(time);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Text(
            '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
            style: BLKWDSTypography.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: BLKWDSTypography.bodyMedium),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: BLKWDSColors.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: itemBuilder(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Future<void> _saveConfig() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await AppConfigService.saveConfig(_config);
      setState(() {
        _successMessage = 'Configuration saved successfully';
      });
    } catch (e) {
      LogService.error('Error saving configuration', e);
      setState(() {
        _errorMessage = 'Error saving configuration: ${e.toString()}';
      });
      if (mounted) {
        ErrorService.showErrorSnackBar(context, 'Error saving configuration');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetConfig() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await AppConfigService.resetConfig();
      setState(() {
        _config = AppConfigService.config;
        _successMessage = 'Configuration reset to defaults';
      });
    } catch (e) {
      LogService.error('Error resetting configuration', e);
      setState(() {
        _errorMessage = 'Error resetting configuration: ${e.toString()}';
      });
      if (mounted) {
        ErrorService.showErrorSnackBar(context, 'Error resetting configuration');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
