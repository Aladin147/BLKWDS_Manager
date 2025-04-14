import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Standardized date picker component for BLKWDS Manager
///
/// Provides consistent styling for all date pickers in the app
class BLKWDSDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isRequired;
  final String? errorText;
  final String hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const BLKWDSDatePicker({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.isRequired = false,
    this.errorText,
    this.hintText = 'Select date',
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = selectedDate ?? now;
    final DateTime firstAllowedDate = firstDate ?? DateTime(now.year - 5);
    final DateTime lastAllowedDate = lastDate ?? DateTime(now.year + 5);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate,
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
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayText = selectedDate != null
        ? DateFormat.yMMMd().format(selectedDate!)
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

        // Date picker field with consistent styling
        InkWell(
          onTap: () => _selectDate(context),
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
                    style: selectedDate != null
                        ? BLKWDSTypography.bodyMedium
                        : BLKWDSTypography.bodyMedium.copyWith(
                            color: BLKWDSColors.slateGrey.withValues(alpha: 128), // 0.5 * 255 = 128
                          ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
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
