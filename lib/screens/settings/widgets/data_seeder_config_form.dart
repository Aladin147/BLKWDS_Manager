import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';

/// DataSeederConfigForm
/// Form for configuring the data seeder
class DataSeederConfigForm extends StatefulWidget {
  final DataSeederConfig config;
  final Function(DataSeederConfig) onSave;
  final VoidCallback onCancel;
  final VoidCallback onReseed;

  const DataSeederConfigForm({
    super.key,
    required this.config,
    required this.onSave,
    required this.onCancel,
    required this.onReseed,
  });

  @override
  State<DataSeederConfigForm> createState() => _DataSeederConfigFormState();
}

class _DataSeederConfigFormState extends State<DataSeederConfigForm> {
  final _formKey = GlobalKey<FormState>();

  late DataSeederVolumeType _volumeType;
  late DataSeederRandomizationType _randomizationType;
  late bool _seedMembers;
  late bool _seedGear;
  late bool _seedProjects;
  late bool _seedBookings;
  late bool _seedActivityLogs;
  late bool _seedStudios;
  late bool _includeFutureData;
  late bool _includePastData;
  late bool _seedOnFirstRun;

  @override
  void initState() {
    super.initState();

    // Initialize form fields with config data
    _volumeType = widget.config.volumeType;
    _randomizationType = widget.config.randomizationType;
    _seedMembers = widget.config.seedMembers;
    _seedGear = widget.config.seedGear;
    _seedProjects = widget.config.seedProjects;
    _seedBookings = widget.config.seedBookings;
    _seedActivityLogs = widget.config.seedActivityLogs;
    _seedStudios = widget.config.seedStudios;
    _includeFutureData = widget.config.includeFutureData;
    _includePastData = widget.config.includePastData;
    _seedOnFirstRun = widget.config.seedOnFirstRun;
  }

  /// Save the configuration
  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final config = DataSeederConfig(
        volumeType: _volumeType,
        randomizationType: _randomizationType,
        seedMembers: _seedMembers,
        seedGear: _seedGear,
        seedProjects: _seedProjects,
        seedBookings: _seedBookings,
        seedActivityLogs: _seedActivityLogs,
        seedStudios: _seedStudios,
        includeFutureData: _includeFutureData,
        includePastData: _includePastData,
        seedOnFirstRun: _seedOnFirstRun,
      );

      widget.onSave(config);
    }
  }

  /// Apply a preset configuration
  void _applyPreset(DataSeederConfig preset) {
    setState(() {
      _volumeType = preset.volumeType;
      _randomizationType = preset.randomizationType;
      _seedMembers = preset.seedMembers;
      _seedGear = preset.seedGear;
      _seedProjects = preset.seedProjects;
      _seedBookings = preset.seedBookings;
      _seedActivityLogs = preset.seedActivityLogs;
      _seedStudios = preset.seedStudios;
      _includeFutureData = preset.includeFutureData;
      _includePastData = preset.includePastData;
      _seedOnFirstRun = preset.seedOnFirstRun;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: BLKWDSColors.backgroundMedium,
        boxShadow: [
          BoxShadow(
            color: BLKWDSColors.deepBlack.withValues(alpha: 40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form title
              Text(
                'Data Seeder Configuration',
                style: BLKWDSTypography.titleMedium,
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),

              // Presets
              Text(
                'Presets',
                style: BLKWDSTypography.labelMedium,
              ),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              Wrap(
                spacing: BLKWDSConstants.spacingSmall,
                runSpacing: BLKWDSConstants.spacingSmall,
                children: [
                  BLKWDSButton(
                    label: 'Minimal',
                    type: BLKWDSButtonType.secondary,
                    size: BLKWDSButtonSize.small,
                    onPressed: () => _applyPreset(DataSeederConfig.minimal()),
                  ),
                  BLKWDSButton(
                    label: 'Standard',
                    type: BLKWDSButtonType.secondary,
                    size: BLKWDSButtonSize.small,
                    onPressed: () => _applyPreset(DataSeederConfig.standard()),
                  ),
                  BLKWDSButton(
                    label: 'Comprehensive',
                    type: BLKWDSButtonType.secondary,
                    size: BLKWDSButtonSize.small,
                    onPressed: () => _applyPreset(DataSeederConfig.comprehensive()),
                  ),
                  BLKWDSButton(
                    label: 'Demo',
                    type: BLKWDSButtonType.secondary,
                    size: BLKWDSButtonSize.small,
                    onPressed: () => _applyPreset(DataSeederConfig.demo()),
                  ),
                  BLKWDSButton(
                    label: 'Testing',
                    type: BLKWDSButtonType.secondary,
                    size: BLKWDSButtonSize.small,
                    onPressed: () => _applyPreset(DataSeederConfig.testing()),
                  ),
                  BLKWDSButton(
                    label: 'Development',
                    type: BLKWDSButtonType.secondary,
                    size: BLKWDSButtonSize.small,
                    onPressed: () => _applyPreset(DataSeederConfig.development()),
                  ),
                  BLKWDSButton(
                    label: 'Empty',
                    type: BLKWDSButtonType.secondary,
                    size: BLKWDSButtonSize.small,
                    onPressed: () => _applyPreset(DataSeederConfig.empty()),
                  ),
                ],
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),

              // Volume type
              Text(
                'Data Volume',
                style: BLKWDSTypography.labelMedium,
              ),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              DropdownButtonFormField<DataSeederVolumeType>(
                value: _volumeType,
                decoration: const InputDecoration(
                  labelText: 'Volume Type',
                ),
                items: DataSeederVolumeType.values.map((type) {
                  return DropdownMenuItem<DataSeederVolumeType>(
                    value: type,
                    child: Text(_getVolumeTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _volumeType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),

              // Randomization type
              Text(
                'Randomization',
                style: BLKWDSTypography.labelMedium,
              ),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              DropdownButtonFormField<DataSeederRandomizationType>(
                value: _randomizationType,
                decoration: const InputDecoration(
                  labelText: 'Randomization Type',
                ),
                items: DataSeederRandomizationType.values.map((type) {
                  return DropdownMenuItem<DataSeederRandomizationType>(
                    value: type,
                    child: Text(_getRandomizationTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _randomizationType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),

              // Data types
              Text(
                'Data Types',
                style: BLKWDSTypography.labelMedium,
              ),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              SwitchListTile(
                title: const Text('Seed Members'),
                subtitle: const Text('Create sample members'),
                value: _seedMembers,
                onChanged: (value) {
                  setState(() {
                    _seedMembers = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Seed Gear'),
                subtitle: const Text('Create sample gear'),
                value: _seedGear,
                onChanged: (value) {
                  setState(() {
                    _seedGear = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Seed Projects'),
                subtitle: const Text('Create sample projects'),
                value: _seedProjects,
                onChanged: (value) {
                  setState(() {
                    _seedProjects = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Seed Bookings'),
                subtitle: const Text('Create sample bookings'),
                value: _seedBookings,
                onChanged: (value) {
                  setState(() {
                    _seedBookings = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Seed Activity Logs'),
                subtitle: const Text('Create sample activity logs'),
                value: _seedActivityLogs,
                onChanged: (value) {
                  setState(() {
                    _seedActivityLogs = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Seed Studios'),
                subtitle: const Text('Create sample studios'),
                value: _seedStudios,
                onChanged: (value) {
                  setState(() {
                    _seedStudios = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),

              // Data options
              Text(
                'Data Options',
                style: BLKWDSTypography.labelMedium,
              ),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              SwitchListTile(
                title: const Text('Include Future Data'),
                subtitle: const Text('Create bookings in the future'),
                value: _includeFutureData,
                onChanged: (value) {
                  setState(() {
                    _includeFutureData = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Include Past Data'),
                subtitle: const Text('Create bookings in the past'),
                value: _includePastData,
                onChanged: (value) {
                  setState(() {
                    _includePastData = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Seed on First Run'),
                subtitle: const Text('Automatically seed data on first run'),
                value: _seedOnFirstRun,
                onChanged: (value) {
                  setState(() {
                    _seedOnFirstRun = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: BLKWDSConstants.spacingLarge),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BLKWDSButton(
                    label: 'Cancel',
                    type: BLKWDSButtonType.secondary,
                    onPressed: widget.onCancel,
                  ),
                  Row(
                    children: [
                      BLKWDSButton(
                        label: 'Reseed Database',
                        type: BLKWDSButtonType.danger,
                        onPressed: widget.onReseed,
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingSmall),
                      BLKWDSButton(
                        label: 'Save Configuration',
                        type: BLKWDSButtonType.primary,
                        onPressed: _saveConfig,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get the label for a volume type
  String _getVolumeTypeLabel(DataSeederVolumeType type) {
    switch (type) {
      case DataSeederVolumeType.minimal:
        return 'Minimal (1-2 of each entity)';
      case DataSeederVolumeType.standard:
        return 'Standard (5-10 of each entity)';
      case DataSeederVolumeType.comprehensive:
        return 'Comprehensive (20+ of each entity)';
    }
  }

  /// Get the label for a randomization type
  String _getRandomizationTypeLabel(DataSeederRandomizationType type) {
    switch (type) {
      case DataSeederRandomizationType.fixed:
        return 'Fixed (same data every time)';
      case DataSeederRandomizationType.semiRandomized:
        return 'Semi-randomized (fixed structure with some randomization)';
      case DataSeederRandomizationType.fullyRandomized:
        return 'Fully randomized (completely random data)';
    }
  }
}
