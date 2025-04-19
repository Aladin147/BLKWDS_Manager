import 'package:flutter/material.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_button.dart';
import '../../widgets/blkwds_checkbox.dart';

/// DataExportDialog
/// A dialog that allows users to select which data to export
class DataExportDialog extends StatefulWidget {
  const DataExportDialog({Key? key}) : super(key: key);

  @override
  _DataExportDialogState createState() => _DataExportDialogState();
}

class _DataExportDialogState extends State<DataExportDialog> {
  // Export options
  bool _exportMembers = true;
  bool _exportProjects = true;
  bool _exportGear = true;
  bool _exportBookings = true;
  bool _exportStudios = true;
  bool _exportActivityLogs = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: BLKWDSColors.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Data',
              style: BLKWDSTypography.titleLarge,
            ),
            SizedBox(height: BLKWDSConstants.spacingSmall),
            Text(
              'Select the data you want to export to CSV files:',
              style: BLKWDSTypography.bodyMedium,
            ),
            SizedBox(height: BLKWDSConstants.spacingMedium),
            _buildExportOptions(),
            SizedBox(height: BLKWDSConstants.spacingMedium),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptions() {
    return Column(
      children: [
        _buildCheckboxOption(
          'Members',
          _exportMembers,
          (value) => setState(() => _exportMembers = value ?? true),
        ),
        _buildCheckboxOption(
          'Projects',
          _exportProjects,
          (value) => setState(() => _exportProjects = value ?? true),
        ),
        _buildCheckboxOption(
          'Gear Inventory',
          _exportGear,
          (value) => setState(() => _exportGear = value ?? true),
        ),
        _buildCheckboxOption(
          'Bookings',
          _exportBookings,
          (value) => setState(() => _exportBookings = value ?? true),
        ),
        _buildCheckboxOption(
          'Studios',
          _exportStudios,
          (value) => setState(() => _exportStudios = value ?? true),
        ),
        _buildCheckboxOption(
          'Activity Logs',
          _exportActivityLogs,
          (value) => setState(() => _exportActivityLogs = value ?? true),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: BLKWDSCheckbox(
        label: label,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BLKWDSButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(null),
          type: BLKWDSButtonType.secondary,
        ),
        SizedBox(width: BLKWDSConstants.spacingSmall),
        BLKWDSButton(
          label: 'Export',
          onPressed: _atLeastOneSelected() ? _handleExport : null,
          type: BLKWDSButtonType.primary,
        ),
      ],
    );
  }

  bool _atLeastOneSelected() {
    return _exportMembers ||
        _exportProjects ||
        _exportGear ||
        _exportBookings ||
        _exportStudios ||
        _exportActivityLogs;
  }

  void _handleExport() {
    Navigator.of(context).pop({
      'members': _exportMembers,
      'projects': _exportProjects,
      'gear': _exportGear,
      'bookings': _exportBookings,
      'studios': _exportStudios,
      'activityLogs': _exportActivityLogs,
    });
  }
}
