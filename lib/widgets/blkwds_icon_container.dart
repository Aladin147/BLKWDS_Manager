import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import 'blkwds_icon.dart';

/// Container sizes for the icon container
enum BLKWDSIconContainerSize {
  /// Extra small container (24px)
  extraSmall(24),

  /// Small container (32px)
  small(32),

  /// Medium container (40px)
  medium(40),

  /// Large container (48px)
  large(48),

  /// Extra large container (56px)
  extraLarge(56);

  final double size;
  const BLKWDSIconContainerSize(this.size);
}

/// Standardized icon container component for BLKWDS Manager
///
/// Provides consistent styling for icon containers throughout the app
class BLKWDSIconContainer extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The size of the container
  final BLKWDSIconContainerSize size;

  /// The background color of the container
  final Color? backgroundColor;

  /// The alpha value for the background color (0-255)
  final int? backgroundAlpha;

  /// The color of the icon
  final Color? iconColor;

  /// The size of the icon
  final double? iconSize;

  /// The border radius of the container
  final double? borderRadius;

  /// The padding around the icon
  final EdgeInsetsGeometry? padding;

  /// The callback when the container is tapped
  final VoidCallback? onTap;

  /// The tooltip to display when hovering over the container
  final String? tooltip;

  /// Whether to show a badge on the icon
  final bool hasBadge;

  /// The color of the badge
  final Color? badgeColor;

  /// Creates a standardized icon container
  const BLKWDSIconContainer({
    super.key,
    required this.icon,
    this.size = BLKWDSIconContainerSize.medium,
    this.backgroundColor,
    this.backgroundAlpha = 50,
    this.iconColor,
    this.iconSize,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.tooltip,
    this.hasBadge = false,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? BLKWDSColors.accentTeal;
    final Color iconCol = iconColor ?? bgColor;
    final double iconSz = iconSize ?? size.size * 0.5;
    final double borderRad = borderRadius ?? BLKWDSConstants.borderRadius;
    
    final container = Container(
      width: size.size,
      height: size.size,
      padding: padding ?? const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: backgroundAlpha ?? 50),
        borderRadius: BorderRadius.circular(borderRad),
      ),
      child: Icon(
        icon,
        color: iconCol,
        size: iconSz,
      ),
    );

    Widget result = container;

    // Add tooltip if provided
    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    // Add tap functionality if provided
    if (onTap != null) {
      result = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRad),
        child: result,
      );
    }

    // Add badge if requested
    if (hasBadge) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: badgeColor ?? BLKWDSColors.errorRed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: BLKWDSColors.deepBlack,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return result;
  }
}
