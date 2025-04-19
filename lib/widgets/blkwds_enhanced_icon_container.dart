import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_shadows.dart';

/// BLKWDSEnhancedIconContainerSize
/// Enum for enhanced icon container sizes
enum BLKWDSEnhancedIconContainerSize {
  /// Small size (32x32)
  small,

  /// Medium size (48x48)
  medium,

  /// Large size (64x64)
  large,
}

/// BLKWDSEnhancedIconContainer
/// An enhanced container with an icon and a colored background
class BLKWDSEnhancedIconContainer extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The size of the container
  final BLKWDSEnhancedIconContainerSize size;

  /// The background color of the container
  final Color backgroundColor;

  /// The alpha value for the background color
  final int backgroundAlpha;

  /// The color of the icon
  final Color iconColor;

  /// Whether to show a shadow
  final bool hasShadow;

  /// Whether to show a border
  final bool hasBorder;

  /// The border color
  final Color? borderColor;

  /// The border width
  final double borderWidth;

  /// The border radius
  final double? borderRadius;

  /// Constructor
  const BLKWDSEnhancedIconContainer({
    super.key,
    required this.icon,
    this.size = BLKWDSEnhancedIconContainerSize.medium,
    this.backgroundColor = BLKWDSColors.infoBlue,
    this.backgroundAlpha = BLKWDSColors.alphaLow,
    this.iconColor = BLKWDSColors.infoBlue,
    this.hasShadow = true,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Determine container size
    double containerSize;
    double iconSize;

    switch (size) {
      case BLKWDSEnhancedIconContainerSize.small:
        containerSize = 32;
        iconSize = 16;
        break;
      case BLKWDSEnhancedIconContainerSize.medium:
        containerSize = 48;
        iconSize = 24;
        break;
      case BLKWDSEnhancedIconContainerSize.large:
        containerSize = 64;
        iconSize = 32;
        break;
    }

    final effectiveBorderRadius = borderRadius ?? BLKWDSConstants.borderRadius;
    final effectiveBorderColor = borderColor ?? iconColor;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: backgroundColor.withAlpha(backgroundAlpha),
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: hasBorder ? Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ) : null,
        boxShadow: hasShadow ? BLKWDSShadows.getShadow(BLKWDSShadows.level1) : null,
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
