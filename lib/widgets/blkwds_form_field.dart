import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// BLKWDSFormField
/// A standardized form field with error display
class BLKWDSFormField extends StatelessWidget {
  /// The label text for the form field
  final String label;

  /// The hint text for the form field
  final String? hintText;

  /// The error text to display
  final String? errorText;

  /// Whether the field is required
  final bool isRequired;

  /// Whether the field is enabled
  final bool enabled;

  /// The controller for the text field
  final TextEditingController? controller;

  /// The focus node for the text field
  final FocusNode? focusNode;

  /// The keyboard type for the text field
  final TextInputType keyboardType;

  /// The text input action for the text field
  final TextInputAction? textInputAction;

  /// The callback when the text field is submitted
  final ValueChanged<String>? onSubmitted;

  /// The callback when the text field is changed
  final ValueChanged<String>? onChanged;

  /// The validator for the text field
  final FormFieldValidator<String>? validator;

  /// The maximum number of lines for the text field
  final int? maxLines;

  /// The minimum number of lines for the text field
  final int? minLines;

  /// The maximum length of the text field
  final int? maxLength;

  /// Whether to obscure the text
  final bool obscureText;

  /// The prefix icon for the text field
  final IconData? prefixIcon;

  /// The suffix icon for the text field
  final IconData? suffixIcon;

  /// The callback when the suffix icon is pressed
  final VoidCallback? onSuffixIconPressed;

  /// The input decoration for the text field
  final InputDecoration? decoration;

  /// The text style for the text field
  final TextStyle? style;

  /// The auto-validation mode for the text field
  final AutovalidateMode? autovalidateMode;

  /// The text capitalization for the text field
  final TextCapitalization textCapitalization;

  /// The text align for the text field
  final TextAlign textAlign;

  /// The text direction for the text field
  final TextDirection? textDirection;

  /// The auto-correct setting for the text field
  final bool autocorrect;

  /// The enable suggestions setting for the text field
  final bool enableSuggestions;

  /// The enable interactive selection setting for the text field
  final bool enableInteractiveSelection;

  /// The expands setting for the text field
  final bool expands;

  /// The read-only setting for the text field
  final bool readOnly;

  /// The show cursor setting for the text field
  final bool? showCursor;

  /// The cursor color for the text field
  final Color? cursorColor;

  /// The cursor height for the text field
  final double? cursorHeight;

  /// The cursor width for the text field
  final double? cursorWidth;

  /// The cursor radius for the text field
  final Radius? cursorRadius;

  /// The input formatters for the text field
  final List<TextInputFormatter>? inputFormatters;

  /// The key for the text field
  final Key? textFieldKey;

  const BLKWDSFormField({
    super.key,
    required this.label,
    this.hintText,
    this.errorText,
    this.isRequired = false,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.decoration,
    this.style,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enableInteractiveSelection = true,
    this.expands = false,
    this.readOnly = false,
    this.showCursor,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth,
    this.cursorRadius,
    this.inputFormatters,
    this.textFieldKey,
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
                color: BLKWDSColors.textSecondary,
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
          key: textFieldKey,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          obscureText: obscureText,
          enabled: enabled,
          style: style ?? BLKWDSTypography.bodyMedium.copyWith(
            color: BLKWDSColors.textPrimary,
          ),
          autovalidateMode: autovalidateMode,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          textDirection: textDirection,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          enableInteractiveSelection: enableInteractiveSelection,
          expands: expands,
          readOnly: readOnly,
          showCursor: showCursor,
          cursorColor: cursorColor ?? BLKWDSColors.accentTeal,
          cursorHeight: cursorHeight,
          cursorWidth: cursorWidth ?? 2.0,
          cursorRadius: cursorRadius ?? const Radius.circular(1.0),
          inputFormatters: inputFormatters,
          decoration: decoration ?? InputDecoration(
            hintText: hintText,
            hintStyle: BLKWDSTypography.bodyMedium.copyWith(
              color: BLKWDSColors.textSecondary.withValues(alpha: 128),
            ),
            errorText: errorText,
            errorStyle: BLKWDSTypography.bodySmall.copyWith(
              color: BLKWDSColors.errorRed,
            ),
            errorMaxLines: 2,
            prefixIcon: prefixIcon != null ? Icon(
              prefixIcon,
              color: BLKWDSColors.textSecondary,
              size: BLKWDSConstants.iconSizeSmall,
            ) : null,
            suffixIcon: suffixIcon != null ? IconButton(
              icon: Icon(
                suffixIcon,
                color: BLKWDSColors.textSecondary,
                size: BLKWDSConstants.iconSizeSmall,
              ),
              onPressed: onSuffixIconPressed,
            ) : null,
            filled: true,
            fillColor: BLKWDSColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: BLKWDSConstants.inputHorizontalPadding,
              vertical: BLKWDSConstants.inputVerticalPadding,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: BLKWDSColors.inputBorder,
                width: BLKWDSConstants.inputBorderWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: BorderSide(
                color: errorText != null ? BLKWDSColors.errorRed : BLKWDSColors.inputBorder,
                width: BLKWDSConstants.inputBorderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: BorderSide(
                color: errorText != null ? BLKWDSColors.errorRed : BLKWDSColors.accentTeal,
                width: BLKWDSConstants.inputFocusBorderWidth,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: BLKWDSColors.errorRed,
                width: BLKWDSConstants.inputBorderWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: BLKWDSColors.errorRed,
                width: BLKWDSConstants.inputFocusBorderWidth,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
              borderSide: BorderSide(
                color: BLKWDSColors.inputBorder.withValues(alpha: 128),
                width: BLKWDSConstants.inputBorderWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
