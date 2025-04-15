import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Standardized text field component for BLKWDS Manager
///
/// Provides consistent styling for all text fields in the app
class BLKWDSTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final bool isRequired;
  final bool isReadOnly;
  final bool isMultiline;
  final String? errorText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final IconData? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final int? maxLength;
  final int? maxLines;
  final String? initialValue;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final String? Function(String?)? validator;

  const BLKWDSTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isMultiline = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.focusNode,
    this.maxLength,
    this.maxLines,
    this.initialValue,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.validator,
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

        // Text field with consistent styling
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          readOnly: isReadOnly,
          maxLines: maxLines ?? (isMultiline ? 5 : 1),
          minLines: isMultiline ? 3 : 1,
          keyboardType: isMultiline ? TextInputType.multiline : keyboardType,
          maxLength: maxLength,
          style: BLKWDSTypography.bodyMedium,
          onChanged: onChanged,
          enabled: enabled,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: BLKWDSTypography.bodyMedium.copyWith(
              color: BLKWDSColors.textHint,
            ),
            errorText: errorText,
            errorStyle: BLKWDSTypography.bodySmall.copyWith(
              color: BLKWDSColors.errorRed,
            ),
            helperText: helperText,
            helperStyle: BLKWDSTypography.bodySmall.copyWith(
              color: BLKWDSColors.textSecondary,
            ),
            filled: true,
            fillColor: BLKWDSColors.inputBackground,
            contentPadding: EdgeInsets.symmetric(
              horizontal: BLKWDSConstants.inputHorizontalPadding,
              vertical: BLKWDSConstants.inputVerticalPadding,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: BLKWDSColors.inputBorder,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: BLKWDSColors.inputBorder,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: BLKWDSColors.accentTeal,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: BLKWDSColors.errorRed,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: BLKWDSColors.errorRed,
                width: 2.0,
              ),
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            prefixText: prefixText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
