import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_shadows.dart';
import 'blkwds_enhanced_text.dart';

/// BLKWDSEnhancedSegmentedButton
/// An enhanced segmented button with consistent styling
class BLKWDSEnhancedSegmentedButton<T> extends StatelessWidget {
  /// The list of segments to display
  final List<BLKWDSEnhancedSegment<T>> segments;

  /// The currently selected value
  final T selectedValue;

  /// Callback when a segment is selected
  final Function(T) onSegmentSelected;

  /// Whether to show icons
  final bool showIcons;

  /// Whether to show labels
  final bool showLabels;

  /// Whether to use a compact layout
  final bool isCompact;

  /// The primary color for the selected segment
  final Color? primaryColor;

  /// Constructor
  const BLKWDSEnhancedSegmentedButton({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onSegmentSelected,
    this.showIcons = true,
    this.showLabels = true,
    this.isCompact = false,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePrimaryColor = primaryColor ?? BLKWDSColors.blkwdsGreen;

    return Container(
      constraints: const BoxConstraints(minHeight: 40, minWidth: 200),
      decoration: BoxDecoration(
        color: BLKWDSColors.backgroundMedium,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        boxShadow: BLKWDSShadows.getShadow(BLKWDSShadows.level1),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: segments.map((segment) {
            final isSelected = segment.value == selectedValue;

            return Flexible(
            child: InkWell(
              onTap: () => onSegmentSelected(segment.value),
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? BLKWDSConstants.spacingXSmall : BLKWDSConstants.spacingSmall,
                  vertical: isCompact ? BLKWDSConstants.spacingXXSmall : BLKWDSConstants.spacingXSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? effectivePrimaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showIcons && segment.icon != null) ...[
                      Icon(
                        segment.icon,
                        size: isCompact ? 16 : 20,
                        color: isSelected ? BLKWDSColors.white : BLKWDSColors.textSecondary,
                      ),
                      if (showLabels) SizedBox(width: isCompact ? 4 : 8),
                    ],
                    if (showLabels)
                      BLKWDSEnhancedText.bodyMedium(
                        segment.label,
                        color: isSelected ? BLKWDSColors.white : BLKWDSColors.textSecondary,
                        isBold: isSelected,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        ),
      ),
    );
  }
}

/// BLKWDSEnhancedSegment
/// A segment for the enhanced segmented button
class BLKWDSEnhancedSegment<T> {
  /// The value of the segment
  final T value;

  /// The label to display
  final String label;

  /// The icon to display
  final IconData? icon;

  /// Constructor
  const BLKWDSEnhancedSegment({
    required this.value,
    required this.label,
    this.icon,
  });
}
