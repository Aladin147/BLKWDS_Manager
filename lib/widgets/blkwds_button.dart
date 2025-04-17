import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Standardized button component for BLKWDS Manager
///
/// Provides consistent styling for all buttons in the app
/// with primary, secondary, and danger variants
enum BLKWDSButtonType {
  primary,
  secondary,
  danger,
}

/// Button size variants
enum BLKWDSButtonSize {
  small,
  medium,
  large,
}

class BLKWDSButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BLKWDSButtonType type;
  final IconData? icon;
  final bool isFullWidth;
  final bool isSmall;
  final BLKWDSButtonSize? size;
  final bool isDisabled;
  final bool isLoading;

  const BLKWDSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = BLKWDSButtonType.primary,
    this.icon,
    this.isFullWidth = false,
    this.isSmall = false,
    this.size,
    this.isDisabled = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine button styling based on type
    Color backgroundColor;
    Color textColor;
    Color? borderColor;

    switch (type) {
      case BLKWDSButtonType.primary:
        backgroundColor = BLKWDSColors.accentTeal;
        textColor = BLKWDSColors.white;
        borderColor = null;
        break;
      case BLKWDSButtonType.secondary:
        backgroundColor = BLKWDSColors.transparent;
        textColor = BLKWDSColors.accentTeal;
        borderColor = BLKWDSColors.accentTeal;
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
    bool useSmallSize = isSmall || size == BLKWDSButtonSize.small;
    bool useLargeSize = size == BLKWDSButtonSize.large;

    double horizontalPadding;
    double verticalPadding;

    if (useSmallSize) {
      horizontalPadding = BLKWDSConstants.buttonHorizontalPadding / 1.5;
      verticalPadding = BLKWDSConstants.buttonVerticalPadding / 1.5;
    } else if (useLargeSize) {
      horizontalPadding = BLKWDSConstants.buttonHorizontalPadding * 1.2;
      verticalPadding = BLKWDSConstants.buttonVerticalPadding * 1.2;
    } else {
      horizontalPadding = BLKWDSConstants.buttonHorizontalPadding;
      verticalPadding = BLKWDSConstants.buttonVerticalPadding;
    }

    // Create button content
    Widget buttonContent;

    if (isLoading) {
      // Show loading spinner
      buttonContent = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: useSmallSize ? 16 : (useLargeSize ? 24 : 20),
            height: useSmallSize ? 16 : (useLargeSize ? 24 : 20),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          SizedBox(width: BLKWDSConstants.spacingSmall),
          Flexible(
            child: Text(
              'Loading...',
              style: useSmallSize
                  ? BLKWDSTypography.labelMedium.copyWith(color: textColor)
                  : (useLargeSize
                      ? BLKWDSTypography.titleSmall.copyWith(color: textColor)
                      : BLKWDSTypography.labelLarge.copyWith(color: textColor)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    } else {
      // Show normal button content
      buttonContent = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor,
              size: useSmallSize ? 16 : (useLargeSize ? 24 : 20),
            ),
            SizedBox(width: BLKWDSConstants.spacingSmall),
          ],
          Flexible(
            child: Text(
              label,
              style: useSmallSize
                  ? BLKWDSTypography.labelMedium.copyWith(color: textColor)
                  : (useLargeSize
                      ? BLKWDSTypography.titleSmall.copyWith(color: textColor)
                      : BLKWDSTypography.labelLarge.copyWith(color: textColor)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

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
          onTap: (isDisabled || isLoading) ? null : onPressed,
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
