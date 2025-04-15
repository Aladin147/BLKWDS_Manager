import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Standardized dropdown component for BLKWDS Manager
///
/// Provides consistent styling for all dropdowns in the app
class BLKWDSDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final bool isRequired;
  final String? errorText;
  final String hintText;

  const BLKWDSDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.hintText = 'Select an option',
  });

  @override
  Widget build(BuildContext context) {
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

        // Dropdown with consistent styling
        Container(
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
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: value,
                hint: Text(
                  hintText,
                  style: BLKWDSTypography.bodyMedium.copyWith(
                    color: BLKWDSColors.slateGrey.withValues(alpha: 128), // 0.5 * 255 = 128
                  ),
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 8,
                style: BLKWDSTypography.bodyMedium,
                dropdownColor: BLKWDSColors.white,
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                items: items,
                onChanged: onChanged,
                padding: EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.inputHorizontalPadding,
                  vertical: BLKWDSConstants.inputVerticalPadding / 2,
                ),
              ),
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
