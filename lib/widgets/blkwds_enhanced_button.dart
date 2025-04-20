import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_style_enhancer.dart';
import '../theme/blkwds_typography.dart';

/// Enhanced Button Types
enum BLKWDSEnhancedButtonType {
  primary,
  secondary,
  tertiary,
  success,
  warning,
  error,
}

/// BLKWDSEnhancedButton
/// An enhanced button widget with consistent styling and animations
class BLKWDSEnhancedButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final BLKWDSEnhancedButtonType type;
  final bool isElevated;
  final bool isLoading;
  final bool animateOnHover;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  const BLKWDSEnhancedButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.type = BLKWDSEnhancedButtonType.primary,
    this.isElevated = true,
    this.isLoading = false,
    this.animateOnHover = true,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  }) : assert(label != null || icon != null, 'Either label or icon must be provided');

  /// Factory constructor for icon-only button
  factory BLKWDSEnhancedButton.icon({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    BLKWDSEnhancedButtonType type = BLKWDSEnhancedButtonType.primary,
    bool isElevated = true,
    bool isLoading = false,
    bool animateOnHover = true,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return BLKWDSEnhancedButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      type: type,
      isElevated: isElevated,
      isLoading: isLoading,
      animateOnHover: animateOnHover,
      padding: padding ?? EdgeInsets.all(BLKWDSConstants.buttonVerticalPaddingMedium),
      width: width ?? BLKWDSConstants.buttonHeightMedium,
      height: height ?? BLKWDSConstants.buttonHeightMedium,
      borderRadius: borderRadius ?? BorderRadius.circular(BLKWDSConstants.borderRadiusRound),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  @override
  State<BLKWDSEnhancedButton> createState() => _BLKWDSEnhancedButtonState();
}

class _BLKWDSEnhancedButtonState extends State<BLKWDSEnhancedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Determine button styling based on type
    final isPrimary = widget.type == BLKWDSEnhancedButtonType.primary;

    // Determine colors based on type
    final backgroundColor = widget.backgroundColor ?? _getBackgroundColor();
    final foregroundColor = widget.foregroundColor ?? _getForegroundColor();

    // Create button style
    final buttonStyle = BLKWDSStyleEnhancer.enhanceButton(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      isPrimary: isPrimary,
      isElevated: widget.isElevated,
    );

    // Create button content
    Widget buttonContent;

    if (widget.isLoading) {
      // Show loading spinner
      buttonContent = SizedBox(
        width: widget.icon != null && widget.label == null
            ? BLKWDSConstants.buttonIconSizeMedium
            : null,
        height: widget.icon != null && widget.label == null
            ? BLKWDSConstants.buttonIconSizeMedium
            : null,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    } else if (widget.icon != null && widget.label != null) {
      // Show icon and label
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: BLKWDSConstants.buttonIconSizeMedium),
          SizedBox(width: BLKWDSConstants.buttonIconPadding),
          Text(
            widget.label!,
            style: widget.textStyle ?? BLKWDSTypography.labelLarge,
          ),
        ],
      );
    } else if (widget.icon != null) {
      // Show icon only
      buttonContent = Icon(widget.icon, size: BLKWDSConstants.buttonIconSizeMedium);
    } else {
      // Show label only
      buttonContent = Text(
        widget.label!,
        style: widget.textStyle ?? BLKWDSTypography.labelLarge,
      );
    }

    // Create base button
    Widget button = ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: buttonStyle,
      child: buttonContent,
    );

    // Add fixed size if specified
    if (widget.width != null || widget.height != null) {
      button = SizedBox(
        width: widget.width,
        height: widget.height,
        child: button,
      );
    }

    // Add hover animation if requested
    if (widget.animateOnHover && !widget.isLoading) {
      button = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: BLKWDSConstants.animationDurationShort,
          child: button,
        ),
      );
    }

    return button;
  }

  // Helper method to determine background color based on button type
  Color _getBackgroundColor() {
    switch (widget.type) {
      case BLKWDSEnhancedButtonType.primary:
        return BLKWDSColors.primaryButtonBackground; // Use the token from color system
      case BLKWDSEnhancedButtonType.secondary:
        return BLKWDSColors.backgroundMedium;
      case BLKWDSEnhancedButtonType.tertiary:
        return Colors.transparent;
      case BLKWDSEnhancedButtonType.success:
        return BLKWDSColors.successGreen;
      case BLKWDSEnhancedButtonType.warning:
        return BLKWDSColors.warningAmber;
      case BLKWDSEnhancedButtonType.error:
        return BLKWDSColors.errorRed;
    }
  }

  // Helper method to determine foreground color based on button type
  Color _getForegroundColor() {
    switch (widget.type) {
      case BLKWDSEnhancedButtonType.primary:
        return BLKWDSColors.primaryButtonText; // Use the token from color system
      case BLKWDSEnhancedButtonType.secondary:
        return BLKWDSColors.secondaryButtonText;
      case BLKWDSEnhancedButtonType.tertiary:
        return BLKWDSColors.primaryButtonBackground; // Match primary button background
      case BLKWDSEnhancedButtonType.success:
        return BLKWDSColors.deepBlack;
      case BLKWDSEnhancedButtonType.warning:
        return BLKWDSColors.deepBlack;
      case BLKWDSEnhancedButtonType.error:
        return BLKWDSColors.white;
    }
  }
}
