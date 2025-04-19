import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_shadows.dart';
import 'blkwds_enhanced_text.dart';

/// BLKWDSEnhancedDropdown
/// An enhanced dropdown component with consistent styling for BLKWDS Manager
class BLKWDSEnhancedDropdown<T> extends StatefulWidget {
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
  State<BLKWDSEnhancedDropdown<T>> createState() => _BLKWDSEnhancedDropdownState<T>();
}

class _BLKWDSEnhancedDropdownState<T> extends State<BLKWDSEnhancedDropdown<T>> {
  T? _effectiveValue;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _updateEffectiveValue();
  }

  @override
  void didUpdateWidget(BLKWDSEnhancedDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.items != widget.items) {
      _updateEffectiveValue();
    }
  }

  void _updateEffectiveValue() {
    // If value is null, no need to check
    if (widget.value == null) {
      _effectiveValue = null;
      _initialized = true;
      return;
    }

    // Check if the value exists in the items list
    bool valueExists = false;
    for (var item in widget.items) {
      if (_areValuesEqual(item.value, widget.value)) {
        valueExists = true;
        break;
      }
    }

    // Set the effective value based on existence
    _effectiveValue = valueExists ? widget.value : null;
    _initialized = true;

    // If the value doesn't exist and it's not null, notify the parent
    if (!valueExists && widget.value != null && mounted) {
      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() {
        if (mounted) {
          widget.onChanged(null);
        }
      });
    }
  }

  /// Helper method to compare values for equality
  /// This handles both primitive types and complex objects
  bool _areValuesEqual(T? a, T? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    // For primitive types, use == operator
    if (a is String || a is num || a is bool) {
      return a == b;
    }

    // For complex objects, compare toString() representations
    // This is a simple approach that works for most cases
    return a.toString() == b.toString();
  }

  @override
  Widget build(BuildContext context) {
    // If not initialized yet, show a placeholder
    if (!_initialized) {
      return const SizedBox.shrink();
    }

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
              text: widget.label,
              style: BLKWDSEnhancedText.getLabelMediumStyle().copyWith(
                color: BLKWDSColors.slateGrey,
              ),
              children: widget.isRequired
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
              color: widget.errorText != null
                  ? BLKWDSColors.errorRed
                  : BLKWDSColors.inputBorder,
              width: 1.0,
            ),
            boxShadow: BLKWDSShadows.getShadow(BLKWDSShadows.level2),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.inputHorizontalPadding,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: _effectiveValue,
              hint: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(widget.prefixIcon, color: BLKWDSColors.accentTeal),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),
                  ],
                  Expanded(
                    child: BLKWDSEnhancedText.bodyMedium(
                      widget.hintText,
                      color: BLKWDSColors.textHint,
                    ),
                  ),
                ],
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
              items: widget.items,
              onChanged: widget.enabled ? widget.onChanged : null,
              padding: const EdgeInsets.symmetric(
                vertical: BLKWDSConstants.inputVerticalPadding / 2,
              ),
            ),
          ),
        ),

        // Error text if provided
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: BLKWDSConstants.spacingSmall / 2,
              left: BLKWDSConstants.spacingSmall,
            ),
            child: BLKWDSEnhancedText.bodySmall(
              widget.errorText!,
              color: BLKWDSColors.errorRed,
            ),
          ),
      ],
    );
  }
}
