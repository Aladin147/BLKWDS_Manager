import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_shadows.dart';
import 'blkwds_enhanced_text.dart';

/// BLKWDSEnhancedFormField
/// An enhanced form field with consistent styling
class BLKWDSEnhancedFormField extends StatelessWidget {
  /// The controller for the text field
  final TextEditingController? controller;

  /// The label text
  final String label;

  /// The hint text
  final String? hintText;

  /// The prefix icon
  final IconData? prefixIcon;

  /// The suffix icon
  final IconData? suffixIcon;

  /// The suffix icon button
  final VoidCallback? onSuffixIconPressed;

  /// The validator function
  final String? Function(String?)? validator;

  /// The on changed callback
  final Function(String)? onChanged;

  /// Whether the field is required
  final bool isRequired;

  /// Whether the field is enabled
  final bool isEnabled;

  /// Whether the field is obscured (for passwords)
  final bool isObscured;

  /// The keyboard type
  final TextInputType keyboardType;

  /// The text input action
  final TextInputAction? textInputAction;

  /// The focus node
  final FocusNode? focusNode;

  /// The on field submitted callback
  final Function(String)? onFieldSubmitted;

  /// The maximum number of lines
  final int? maxLines;

  /// The minimum number of lines
  final int? minLines;

  /// The maximum length
  final int? maxLength;

  /// Constructor
  const BLKWDSEnhancedFormField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.onChanged,
    this.isRequired = false,
    this.isEnabled = true,
    this.isObscured = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Row(
          children: [
            BLKWDSEnhancedText.labelLarge(
              label,
              color: isEnabled ? BLKWDSColors.textPrimary : BLKWDSColors.textSecondary,
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              BLKWDSEnhancedText.labelLarge(
                '*',
                color: BLKWDSColors.errorRed,
              ),
            ],
          ],
        ),
        const SizedBox(height: BLKWDSConstants.spacingXSmall),

        // Text field
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            filled: true,
            fillColor: isEnabled
                ? BLKWDSColors.backgroundMedium
                : BLKWDSColors.backgroundMedium.withValues(alpha: 150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              borderSide: BorderSide(
                color: BLKWDSColors.slateGrey.withValues(alpha: 100),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              borderSide: BorderSide(
                color: BLKWDSColors.slateGrey.withValues(alpha: 100),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              borderSide: BorderSide(
                color: BLKWDSColors.blkwdsGreen,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              borderSide: BorderSide(
                color: BLKWDSColors.errorRed,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              borderSide: BorderSide(
                color: BLKWDSColors.errorRed,
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: BLKWDSConstants.spacingMedium,
              vertical: BLKWDSConstants.spacingSmall,
            ),
          ),
          style: TextStyle(
            color: isEnabled ? BLKWDSColors.textPrimary : BLKWDSColors.textSecondary,
          ),
          validator: validator,
          onChanged: onChanged,
          enabled: isEnabled,
          obscureText: isObscured,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
        ),
      ],
    );
  }
}
