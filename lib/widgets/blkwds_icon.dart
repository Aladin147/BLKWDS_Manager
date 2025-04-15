import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';

/// Icon sizes for the application
enum BLKWDSIconSize {
  /// Extra small icon (16px)
  extraSmall(16),

  /// Small icon (20px)
  small(20),

  /// Medium icon (24px)
  medium(24),

  /// Large icon (32px)
  large(32),

  /// Extra large icon (48px)
  extraLarge(48);

  final double size;
  const BLKWDSIconSize(this.size);
}

/// Standardized icon component for BLKWDS Manager
///
/// Provides consistent styling for all icons in the app
class BLKWDSIcon extends StatelessWidget {
  final IconData icon;
  final BLKWDSIconSize size;
  final Color? color;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool hasBadge;
  final Color? badgeColor;

  const BLKWDSIcon({
    super.key,
    required this.icon,
    this.size = BLKWDSIconSize.medium,
    this.color,
    this.onTap,
    this.tooltip,
    this.hasBadge = false,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: size.size,
      color: color ?? BLKWDSColors.electricMint,
    );

    Widget result = iconWidget;

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
        borderRadius: BorderRadius.circular(size.size),
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
