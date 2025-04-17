import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/app_theme.dart';
import '../../config/environment_config.dart';

/// Dialog for configuring data seeding options
class DataSeedingDialog extends StatefulWidget {
  /// Constructor
  const DataSeedingDialog({super.key});

  @override
  State<DataSeedingDialog> createState() => _DataSeedingDialogState();
}

class _DataSeedingDialogState extends State<DataSeedingDialog> {
  late DataSeederConfig _config;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  /// Load the current data seeder configuration
  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final config = await DataSeeder.getConfig();
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (e) {
      LogService.error('Error loading data seeder config', e);
      setState(() {
        _config = DataSeederConfig.standard();
        _isLoading = false;
      });
    }
  }

  /// Save the data seeder configuration
  Future<void> _saveConfig() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await DataSeeder.saveConfig(_config);
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          'Data seeder configuration saved',
        );
      }
    } catch (e) {
      LogService.error('Error saving data seeder config', e);
      if (mounted) {
        SnackbarService.showError(
          context,
          'Error saving data seeder configuration',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Reseed the database with the current configuration
  Future<void> _reseedDatabase() async {
    // Check if we're in production environment
    if (EnvironmentConfig.isProduction) {
      if (mounted) {
        SnackbarService.showError(
          context,
          'Database reseeding is disabled in production environment',
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Database Reset'),
        content: const Text(
          'This will delete all existing data and replace it with sample data. '
          'This action cannot be undone. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset Database'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await DataSeeder.reseedDatabase(_config);
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          'Database reseeded successfully',
        );
      }
    } catch (e) {
      LogService.error('Error reseeding database', e);
      if (mounted) {
        SnackbarService.showError(
          context,
          'Error reseeding database',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Show warning dialog in production environment
    if (EnvironmentConfig.isProduction) {
      return AlertDialog(
        title: const Text('Data Seeding Disabled'),
        content: const Text(
          'Data seeding is disabled in production environment to prevent accidental data loss. '
          'This feature is only available in development and testing environments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Data Seeding Configuration'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configure how sample data is generated for the application. '
                'These settings only apply when seeding the database with sample data.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Seed on first run
              SwitchListTile(
                title: const Text('Seed on First Run'),
                subtitle: const Text(
                  'Automatically seed the database with sample data when the app is first run',
                ),
                value: _config.seedOnFirstRun,
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(seedOnFirstRun: value);
                  });
                },
              ),

              const Divider(),

              // Volume type
              const Text('Data Volume', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<DataSeederVolumeType>(
                value: _config.volumeType,
                items: DataSeederVolumeType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getVolumeTypeLabel(type)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _config = _config.copyWith(volumeType: value);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Randomization type
              const Text('Randomization', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<DataSeederRandomizationType>(
                value: _config.randomizationType,
                items: DataSeederRandomizationType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getRandomizationTypeLabel(type)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _config = _config.copyWith(randomizationType: value);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Data types to seed
              const Text('Data Types to Seed', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Members'),
                value: _config.seedMembers,
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(seedMembers: value ?? false);
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Gear'),
                value: _config.seedGear,
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(seedGear: value ?? false);
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Projects'),
                value: _config.seedProjects,
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(seedProjects: value ?? false);
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Bookings'),
                value: _config.seedBookings,
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(seedBookings: value ?? false);
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Studios'),
                value: _config.seedStudios,
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(seedStudios: value ?? false);
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Activity Logs'),
                value: _config.seedActivityLogs,
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(seedActivityLogs: value ?? false);
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveConfig,
          child: _isSaving
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Saving...'),
                  ],
                )
              : const Text('Save Configuration'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isSaving ? null : _reseedDatabase,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
          child: _isSaving
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Reseeding...'),
                  ],
                )
              : const Text('Reset & Reseed Database'),
        ),
      ],
    );
  }

  /// Get a human-readable label for a volume type
  String _getVolumeTypeLabel(DataSeederVolumeType type) {
    switch (type) {
      case DataSeederVolumeType.minimal:
        return 'Minimal - Few sample items';
      case DataSeederVolumeType.standard:
        return 'Standard - Moderate sample data';
      case DataSeederVolumeType.comprehensive:
        return 'Comprehensive - Extensive sample data';
    }
  }

  /// Get a human-readable label for a randomization type
  String _getRandomizationTypeLabel(DataSeederRandomizationType type) {
    switch (type) {
      case DataSeederRandomizationType.fixed:
        return 'Fixed - Consistent sample data';
      case DataSeederRandomizationType.semiRandomized:
        return 'Semi-randomized - Some randomization';
      case DataSeederRandomizationType.fullyRandomized:
        return 'Fully randomized - Complete randomization';
    }
  }
}
