import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';

/// StudioSettingsForm
/// Form for configuring studio settings
class StudioSettingsForm extends StatefulWidget {
  final StudioSettings settings;
  final Function(StudioSettings) onSave;
  final VoidCallback onCancel;

  const StudioSettingsForm({
    super.key,
    required this.settings,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<StudioSettingsForm> createState() => _StudioSettingsFormState();
}

class _StudioSettingsFormState extends State<StudioSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TimeOfDay _openingTime;
  late TimeOfDay _closingTime;
  late int _minBookingDuration;
  late int _maxBookingDuration;
  late int _minAdvanceBookingTime;
  late int _maxAdvanceBookingTime;
  late int _cleanupTime;
  late bool _allowOverlappingBookings;
  late bool _enforceStudioHours;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize form fields with settings
    _openingTime = widget.settings.openingTime;
    _closingTime = widget.settings.closingTime;
    _minBookingDuration = widget.settings.minBookingDuration;
    _maxBookingDuration = widget.settings.maxBookingDuration;
    _minAdvanceBookingTime = widget.settings.minAdvanceBookingTime;
    _maxAdvanceBookingTime = widget.settings.maxAdvanceBookingTime;
    _cleanupTime = widget.settings.cleanupTime;
    _allowOverlappingBookings = widget.settings.allowOverlappingBookings;
    _enforceStudioHours = widget.settings.enforceStudioHours;
  }
  
  /// Pick opening time
  Future<void> _pickOpeningTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _openingTime,
    );
    
    if (pickedTime != null) {
      setState(() {
        _openingTime = pickedTime;
      });
    }
  }
  
  /// Pick closing time
  Future<void> _pickClosingTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _closingTime,
    );
    
    if (pickedTime != null) {
      setState(() {
        _closingTime = pickedTime;
      });
    }
  }
  
  /// Save settings
  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final settings = widget.settings.copyWith(
        openingTime: _openingTime,
        closingTime: _closingTime,
        minBookingDuration: _minBookingDuration,
        maxBookingDuration: _maxBookingDuration,
        minAdvanceBookingTime: _minAdvanceBookingTime,
        maxAdvanceBookingTime: _maxAdvanceBookingTime,
        cleanupTime: _cleanupTime,
        allowOverlappingBookings: _allowOverlappingBookings,
        enforceStudioHours: _enforceStudioHours,
      );
      
      widget.onSave(settings);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form title
            Text(
              'Studio Settings',
              style: BLKWDSTypography.titleMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            
            // Operating hours
            Text(
              'Operating Hours',
              style: BLKWDSTypography.labelMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickOpeningTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Opening Time',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _openingTime.format(context),
                        style: BLKWDSTypography.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                Expanded(
                  child: InkWell(
                    onTap: _pickClosingTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Closing Time',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _closingTime.format(context),
                        style: BLKWDSTypography.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            
            // Booking duration limits
            Text(
              'Booking Duration Limits',
              style: BLKWDSTypography.labelMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _minBookingDuration.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Minimum (minutes)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration < 15) {
                        return 'Min 15 minutes';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final duration = int.tryParse(value);
                      if (duration != null) {
                        _minBookingDuration = duration;
                      }
                    },
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                Expanded(
                  child: TextFormField(
                    initialValue: _maxBookingDuration.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Maximum (minutes)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration < _minBookingDuration) {
                        return 'Must be >= minimum';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final duration = int.tryParse(value);
                      if (duration != null) {
                        _maxBookingDuration = duration;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            
            // Advance booking limits
            Text(
              'Advance Booking Limits',
              style: BLKWDSTypography.labelMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _minAdvanceBookingTime.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Minimum (hours)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final hours = int.tryParse(value);
                      if (hours == null || hours < 0) {
                        return 'Must be >= 0';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final hours = int.tryParse(value);
                      if (hours != null) {
                        _minAdvanceBookingTime = hours;
                      }
                    },
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                Expanded(
                  child: TextFormField(
                    initialValue: _maxAdvanceBookingTime.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Maximum (days)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final days = int.tryParse(value);
                      if (days == null || days < 1) {
                        return 'Must be >= 1';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final days = int.tryParse(value);
                      if (days != null) {
                        _maxAdvanceBookingTime = days;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            
            // Cleanup time
            TextFormField(
              initialValue: _cleanupTime.toString(),
              decoration: const InputDecoration(
                labelText: 'Cleanup Time Between Bookings (minutes)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final minutes = int.tryParse(value);
                if (minutes == null || minutes < 0) {
                  return 'Must be >= 0';
                }
                return null;
              },
              onChanged: (value) {
                final minutes = int.tryParse(value);
                if (minutes != null) {
                  _cleanupTime = minutes;
                }
              },
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            
            // Booking rules
            Text(
              'Booking Rules',
              style: BLKWDSTypography.labelMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            SwitchListTile(
              title: const Text('Allow Overlapping Bookings'),
              subtitle: const Text('Allow multiple bookings for the same studio at the same time'),
              value: _allowOverlappingBookings,
              onChanged: (value) {
                setState(() {
                  _allowOverlappingBookings = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Enforce Studio Hours'),
              subtitle: const Text('Only allow bookings during operating hours'),
              value: _enforceStudioHours,
              onChanged: (value) {
                setState(() {
                  _enforceStudioHours = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: BLKWDSConstants.spacingLarge),
            
            // Form actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BLKWDSButton(
                  label: 'Cancel',
                  type: BLKWDSButtonType.secondary,
                  onPressed: widget.onCancel,
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                BLKWDSButton(
                  label: 'Save',
                  type: BLKWDSButtonType.primary,
                  onPressed: _saveSettings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
