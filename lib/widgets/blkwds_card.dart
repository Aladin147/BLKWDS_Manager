import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';

/// Standardized card component for BLKWDS Manager
/// 
/// Provides consistent styling for all cards in the app
class BLKWDSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double elevation;

  const BLKWDSCard({
    Key? key,
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
    this.elevation = BLKWDSConstants.cardElevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: child,
    );

    final card = Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 1.0)
            : BorderSide.none,
      ),
      color: BLKWDSColors.cardBackground,
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              child: cardContent,
            )
          : cardContent,
    );

    return card;
  }
}
