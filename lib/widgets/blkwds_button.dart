import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';
import '../theme/blkwds_animations.dart';
import '../theme/blkwds_shadows.dart';
import '../theme/blkwds_gradients.dart';

/// Standardized button component for BLKWDS Manager
///
/// Provides consistent styling for all buttons in the app
/// with primary, secondary, and danger variants
enum BLKWDSButtonType {
  primary,
  secondary,
  danger,
}

class BLKWDSButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final BLKWDSButtonType type;
  final IconData? icon;
  final bool isFullWidth;
  final bool isSmall;
  final bool isDisabled;

  const BLKWDSButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.type = BLKWDSButtonType.primary,
    this.icon,
    this.isFullWidth = false,
    this.isSmall = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button styling based on type
    Color backgroundColor;
    Color textColor;
    Color? borderColor;

    switch (type) {
      case BLKWDSButtonType.primary:
        backgroundColor = BLKWDSColors.primaryButtonBackground;
        textColor = BLKWDSColors.primaryButtonText;
        borderColor = null;
        break;
      case BLKWDSButtonType.secondary:
        backgroundColor = Colors.transparent;
        textColor = BLKWDSColors.slateGrey;
        borderColor = BLKWDSColors.secondaryButtonBorder;
        break;
      case BLKWDSButtonType.danger:
        backgroundColor = BLKWDSColors.errorRed;
        textColor = BLKWDSColors.white;
        borderColor = null;
        break;
    }

    // Apply disabled styling if needed
    if (isDisabled) {
      backgroundColor = backgroundColor.withValues(alpha: 128); // 0.5 * 255 = 128
      textColor = textColor.withValues(alpha: 179); // 0.7 * 255 = 179
      if (borderColor != null) {
        borderColor = borderColor.withValues(alpha: 128); // 0.5 * 255 = 128
      }
    }

    // Determine padding based on size
    final double horizontalPadding = isSmall
        ? BLKWDSConstants.buttonHorizontalPadding / 1.5
        : BLKWDSConstants.buttonHorizontalPadding;

    final double verticalPadding = isSmall
        ? BLKWDSConstants.buttonVerticalPadding / 1.5
        : BLKWDSConstants.buttonVerticalPadding;

    // Create button content
    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: textColor,
            size: isSmall ? 16 : 20,
          ),
          SizedBox(width: BLKWDSConstants.spacingSmall),
        ],
        Text(
          label,
          style: isSmall
              ? BLKWDSTypography.labelMedium.copyWith(color: textColor)
              : BLKWDSTypography.labelLarge.copyWith(color: textColor),
        ),
      ],
    );

    // Create the button with appropriate styling
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(BLKWDSConstants.buttonBorderRadius),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(BLKWDSConstants.buttonBorderRadius),
          child: Container(
            width: isFullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
