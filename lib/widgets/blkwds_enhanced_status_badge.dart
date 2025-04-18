import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';

import '../theme/blkwds_shadows.dart';
import 'blkwds_enhanced_text.dart';

/// BLKWDSEnhancedStatusBadge
/// An enhanced status badge component with consistent styling for BLKWDS Manager
class BLKWDSEnhancedStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final IconData? icon;
  final double? iconSize;
  final bool hasShadow;
  final bool hasBorder;
  final bool isBold;

  const BLKWDSEnhancedStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.icon,
    this.iconSize,
    this.hasShadow = true,
    this.hasBorder = false,
    this.isBold = true,
  });

  /// Create a status badge with a predefined status
  factory BLKWDSEnhancedStatusBadge.status({
    Key? key,
    required String status,
    String? customText,
    IconData? icon,
    bool hasShadow = true,
    bool hasBorder = false,
  }) {
    Color color;
    String text = customText ?? status.toUpperCase();
    IconData statusIcon = icon ?? Icons.circle;

    switch (status.toLowerCase()) {
      case 'active':
      case 'current':
      case 'in':
      case 'available':
        color = BLKWDSColors.statusIn;
        statusIcon = icon ?? Icons.check_circle;
        break;
      case 'upcoming':
      case 'pending':
      case 'scheduled':
        color = BLKWDSColors.electricMint;
        statusIcon = icon ?? Icons.schedule;
        break;
      case 'past':
      case 'completed':
      case 'done':
        color = BLKWDSColors.slateGrey;
        statusIcon = icon ?? Icons.done_all;
        break;
      case 'out':
      case 'warning':
      case 'attention':
        color = BLKWDSColors.statusOut;
        statusIcon = icon ?? Icons.warning_amber;
        break;
      case 'error':
      case 'critical':
      case 'urgent':
        color = BLKWDSColors.errorRed;
        statusIcon = icon ?? Icons.error;
        break;
      default:
        color = BLKWDSColors.slateGrey;
    }

    return BLKWDSEnhancedStatusBadge(
      key: key,
      text: text,
      color: color,
      icon: statusIcon,
      hasShadow: hasShadow,
      hasBorder: hasBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: hasBorder ? Border.all(color: color, width: 1) : null,
        boxShadow: hasShadow ? BLKWDSShadows.getShadow(BLKWDSShadows.level1) : null,
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon!,
                  size: iconSize ?? 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                BLKWDSEnhancedText.labelLarge(
                  text,
                  color: color,
                  isBold: isBold,
                ),
              ],
            )
          : BLKWDSEnhancedText.labelLarge(
              text,
              color: color,
              isBold: isBold,
            ),
    );
  }
}
