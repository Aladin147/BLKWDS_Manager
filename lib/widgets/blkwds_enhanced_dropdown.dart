import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_shadows.dart';
import 'blkwds_enhanced_text.dart';

/// BLKWDSEnhancedDropdown
/// An enhanced dropdown component with consistent styling for BLKWDS Manager
class BLKWDSEnhancedDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final bool isRequired;
  final String? errorText;
  final String hintText;
  final IconData? prefixIcon;
  final bool enabled;
  final String? Function(T?)? validator;
  final AutovalidateMode? autovalidateMode;

  const BLKWDSEnhancedDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.hintText = 'Select an option',
    this.prefixIcon,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
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
              style: BLKWDSEnhancedText.getLabelMediumStyle().copyWith(
                color: BLKWDSColors.slateGrey,
              ),
              children: isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: BLKWDSEnhancedText.getLabelMediumStyle().copyWith(
                          color: BLKWDSColors.errorRed,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
        ),

        // Dropdown with enhanced styling
        Container(
          decoration: BoxDecoration(
            color: BLKWDSColors.backgroundMedium,
            borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
            border: Border.all(
              color: errorText != null
                  ? BLKWDSColors.errorRed
                  : BLKWDSColors.inputBorder,
              width: 1.0,
            ),
            boxShadow: BLKWDSShadows.getShadow(BLKWDSShadows.level2),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: BLKWDSEnhancedText.getBodyMediumStyle().copyWith(
                color: BLKWDSColors.textHint,
              ),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: BLKWDSColors.accentTeal) : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: BLKWDSConstants.inputHorizontalPadding,
                vertical: BLKWDSConstants.inputVerticalPadding,
              ),
              errorStyle: BLKWDSEnhancedText.getBodySmallStyle().copyWith(
                color: BLKWDSColors.errorRed,
              ),
            ),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: BLKWDSColors.accentTeal),
            iconSize: 24,
            elevation: 8,
            style: BLKWDSEnhancedText.getBodyMediumStyle().copyWith(
              color: BLKWDSColors.textPrimary,
            ),
            dropdownColor: BLKWDSColors.backgroundMedium,
            borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
            items: items,
            onChanged: enabled ? onChanged : null,
            validator: validator,
            autovalidateMode: autovalidateMode,
          ),
        ),

        // Error text if provided
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: BLKWDSConstants.spacingSmall / 2,
              left: BLKWDSConstants.spacingSmall,
            ),
            child: BLKWDSEnhancedText.bodySmall(
              errorText!,
              color: BLKWDSColors.errorRed,
            ),
          ),
      ],
    );
  }
}
