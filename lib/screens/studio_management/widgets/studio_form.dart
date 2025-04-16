import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';

/// StudioForm
/// Form for adding or editing a studio
class StudioForm extends StatefulWidget {
  final Studio? studio;
  final Function(Studio) onSave;
  final VoidCallback onCancel;

  const StudioForm({
    super.key,
    this.studio,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<StudioForm> createState() => _StudioFormState();
}

class _StudioFormState extends State<StudioForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _featuresController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  late StudioType _selectedType;
  late StudioStatus _selectedStatus;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();

    // Initialize form fields with studio data if editing
    if (widget.studio != null) {
      _nameController.text = widget.studio!.name;
      _descriptionController.text = widget.studio!.description ?? '';
      _featuresController.text = widget.studio!.features.join(', ');
      _hourlyRateController.text = widget.studio!.hourlyRate?.toString() ?? '';
      _selectedType = widget.studio!.type;
      _selectedStatus = widget.studio!.status;
      _selectedColor = widget.studio!.color;
    } else {
      // Default values for new studio
      _selectedType = StudioType.recording;
      _selectedStatus = StudioStatus.available;
      _selectedColor = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _featuresController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  /// Save the studio
  void _saveStudio() {
    if (_formKey.currentState!.validate()) {
      // Parse features from comma-separated string
      final features = _featuresController.text.isEmpty
          ? <String>[]
          : _featuresController.text.split(',').map((e) => e.trim()).toList();

      // Parse hourly rate
      double? hourlyRate;
      if (_hourlyRateController.text.isNotEmpty) {
        hourlyRate = double.tryParse(_hourlyRateController.text);
      }

      // Create studio object
      final studio = Studio(
        id: widget.studio?.id,
        name: _nameController.text,
        type: _selectedType,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        features: features,
        hourlyRate: hourlyRate,
        status: _selectedStatus,
        color: _selectedColor,
      );

      // Call onSave callback
      widget.onSave(studio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
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
              widget.studio == null ? 'Add Studio' : 'Edit Studio',
              style: BLKWDSTypography.titleMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Name field
            BLKWDSTextField(
              controller: _nameController,
              label: 'Studio Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Type dropdown
            DropdownButtonFormField<StudioType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Studio Type',
              ),
              items: StudioType.values.map((type) {
                return DropdownMenuItem<StudioType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, size: 20),
                      const SizedBox(width: BLKWDSConstants.spacingSmall),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Description field
            BLKWDSTextField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Features field
            BLKWDSTextField(
              controller: _featuresController,
              label: 'Features (comma-separated)',
              helperText: 'e.g. Soundproof, 4K Camera, Green Screen',
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Hourly rate field
            BLKWDSTextField(
              controller: _hourlyRateController,
              label: 'Hourly Rate',
              keyboardType: TextInputType.number,
              prefixText: '\$',
              helperText: 'Leave empty if not applicable',
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Status dropdown
            DropdownButtonFormField<StudioStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: StudioStatus.values.map((status) {
                return DropdownMenuItem<StudioStatus>(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingSmall),
                      Text(status.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Color picker
            Row(
              children: [
                Text(
                  'Color',
                  style: BLKWDSTypography.labelMedium,
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                Expanded(
                  child: Wrap(
                    spacing: BLKWDSConstants.spacingSmall,
                    children: [
                      // No color option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = null;
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == null
                                  ? BLKWDSColors.primaryButtonBackground
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: _selectedColor == null
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: BLKWDSColors.primaryButtonBackground,
                                )
                              : null,
                        ),
                      ),
                      // Color options
                      for (final color in _colorOptions)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: _selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
                  onPressed: _saveStudio,
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  // Color options for studios
  static const List<String> _colorOptions = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#9C27B0', // Purple
    '#F44336', // Red
    '#FF9800', // Orange
    '#FFEB3B', // Yellow
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];
}
