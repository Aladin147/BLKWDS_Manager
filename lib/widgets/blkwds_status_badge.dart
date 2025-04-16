import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_typography.dart';

/// Standardized status badge component for BLKWDS Manager
///
/// Provides consistent styling for status indicators across the app
class BLKWDSStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final IconData? icon;
  final double? iconSize;

  const BLKWDSStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.icon,
    this.iconSize,
  });

  /// Create a status badge with a predefined status
  factory BLKWDSStatusBadge.status({
    Key? key,
    required String status,
    String? customText,
  }) {
    Color color;
    String text = customText ?? status;

    switch (status.toLowerCase()) {
      case 'active':
      case 'current':
      case 'in':
      case 'available':
        color = BLKWDSColors.blkwdsGreen;
        break;
      case 'upcoming':
      case 'pending':
      case 'scheduled':
        color = BLKWDSColors.electricMint;
        break;
      case 'past':
      case 'completed':
      case 'done':
        color = BLKWDSColors.slateGrey;
        break;
      case 'out':
      case 'warning':
      case 'attention':
        color = BLKWDSColors.mustardOrange;
        break;
      case 'error':
      case 'critical':
      case 'urgent':
        color = BLKWDSColors.errorRed;
        break;
      default:
        color = BLKWDSColors.slateGrey;
    }

    return BLKWDSStatusBadge(
      key: key,
      text: text,
      color: color,
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
        color: color.withValues(alpha: 50),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
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
                Text(
                  text,
                  style: (fontSize != null
                          ? BLKWDSTypography.labelSmall.copyWith(fontSize: fontSize)
                          : BLKWDSTypography.labelSmall)
                      .copyWith(
                    color: color,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: (fontSize != null
                      ? BLKWDSTypography.labelSmall.copyWith(fontSize: fontSize)
                      : BLKWDSTypography.labelSmall)
                  .copyWith(
                color: color,
              ),
            ),
    );
  }
}
