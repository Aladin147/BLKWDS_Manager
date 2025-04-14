import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Standardized time picker component for BLKWDS Manager
/// 
/// Provides consistent styling for all time pickers in the app
class BLKWDSTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;
  final bool isRequired;
  final String? errorText;
  final String hintText;

  const BLKWDSTimePicker({
    Key? key,
    required this.label,
    required this.selectedTime,
    required this.onTimeSelected,
    this.isRequired = false,
    this.errorText,
    this.hintText = 'Select time',
  }) : super(key: key);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = selectedTime ?? TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: BLKWDSColors.blkwdsGreen,
              onPrimary: BLKWDSColors.white,
              onSurface: BLKWDSColors.deepBlack,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: BLKWDSColors.blkwdsGreen,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final String displayText = selectedTime != null
        ? _formatTimeOfDay(selectedTime!)
        : hintText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator if needed
        Padding(
          padding: const EdgeInsets.only(
            bottom: BLKWDSConstants.spacingSmall / 2,
            left: BLKWDSConstants.spacingSmall / 2,
          ),
          child: RichText(
            text: TextSpan(
              text: label,
              style: BLKWDSTypography.labelMedium.copyWith(
                color: BLKWDSColors.slateGrey,
              ),
              children: isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: BLKWDSTypography.labelMedium.copyWith(
                          color: BLKWDSColors.errorRed,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
        
        // Time picker field with consistent styling
        InkWell(
          onTap: () => _selectTime(context),
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: BLKWDSConstants.inputHorizontalPadding,
              vertical: BLKWDSConstants.inputVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: BLKWDSColors.inputBackground,
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              border: Border.all(
                color: errorText != null
                    ? BLKWDSColors.errorRed
                    : BLKWDSColors.inputBorder,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: selectedTime != null
                        ? BLKWDSTypography.bodyMedium
                        : BLKWDSTypography.bodyMedium.copyWith(
                            color: BLKWDSColors.slateGrey.withOpacity(0.5),
                          ),
                  ),
                ),
                const Icon(
                  Icons.access_time,
                  color: BLKWDSColors.slateGrey,
                ),
              ],
            ),
          ),
        ),
        
        // Error text if provided
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: BLKWDSConstants.spacingSmall / 2,
              left: BLKWDSConstants.spacingSmall,
            ),
            child: Text(
              errorText!,
              style: BLKWDSTypography.bodySmall.copyWith(
                color: BLKWDSColors.errorRed,
              ),
            ),
          ),
      ],
    );
  }
}
