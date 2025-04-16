import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';
import '../theme/blkwds_animations.dart';
import '../theme/blkwds_shadows.dart';
import '../theme/blkwds_gradients.dart';

/// Enhanced button component for BLKWDS Manager
///
/// Provides consistent styling for all buttons in the app with enhanced
/// visual effects including shadows, gradients, and animations
enum BLKWDSButtonTypeEnhanced {
  /// Primary button with high emphasis
  primary,

  /// Secondary button with medium emphasis
  secondary,

  /// Danger button for destructive actions
  danger,

  /// Success button for positive actions
  success,

  /// Warning button for cautionary actions
  warning,

  /// Text button with minimal styling
  text,

  /// Icon button with only an icon
  icon,
}

class BLKWDSButtonEnhanced extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final BLKWDSButtonTypeEnhanced type;
  final bool isFullWidth;
  final bool isSmall;
  final bool isDisabled;
  final bool useGradient;
  final Gradient? customGradient;
  final bool hasShadow;
  final bool isLoading;
  final bool animateOnHover;
  final Widget? customChild;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? customColor;
  final Color? customTextColor;

  const BLKWDSButtonEnhanced({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.type = BLKWDSButtonTypeEnhanced.primary,
    this.isFullWidth = false,
    this.isSmall = false,
    this.isDisabled = false,
    this.useGradient = true,
    this.customGradient,
    this.hasShadow = true,
    this.isLoading = false,
    this.animateOnHover = true,
    this.customChild,
    this.padding,
    this.width,
    this.height,
    this.customColor,
    this.customTextColor,
  });

  /// Creates an icon-only button
  factory BLKWDSButtonEnhanced.icon({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    BLKWDSButtonTypeEnhanced type = BLKWDSButtonTypeEnhanced.primary,
    bool isSmall = false,
    bool isDisabled = false,
    bool useGradient = true,
    Gradient? customGradient,
    bool hasShadow = true,
    bool isLoading = false,
    bool animateOnHover = true,
    Color? customColor,
    Color? customTextColor,
  }) {
    return BLKWDSButtonEnhanced(
      key: key,
      label: '', // Empty label for icon-only button
      onPressed: onPressed,
      icon: icon,
      type: BLKWDSButtonTypeEnhanced.icon,
      isSmall: isSmall,
      isDisabled: isDisabled,
      useGradient: useGradient,
      customGradient: customGradient,
      hasShadow: hasShadow,
      isLoading: isLoading,
      animateOnHover: animateOnHover,
      customColor: customColor,
      customTextColor: customTextColor,
    );
  }

  /// Creates a text-only button with minimal styling
  factory BLKWDSButtonEnhanced.text({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isSmall = false,
    bool isDisabled = false,
    bool isLoading = false,
    Color? customTextColor,
  }) {
    return BLKWDSButtonEnhanced(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      type: BLKWDSButtonTypeEnhanced.text,
      isSmall: isSmall,
      isDisabled: isDisabled,
      useGradient: false,
      hasShadow: false,
      isLoading: isLoading,
      animateOnHover: true,
      customTextColor: customTextColor,
    );
  }

  @override
  State<BLKWDSButtonEnhanced> createState() => _BLKWDSButtonEnhancedState();
}

class _BLKWDSButtonEnhancedState extends State<BLKWDSButtonEnhanced> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: BLKWDSAnimations.xLong,
    );

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(BLKWDSButtonEnhanced oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine button colors based on type
    Color backgroundColor;
    Color textColor;
    Color? borderColor;
    Gradient? gradient;
    List<BoxShadow> shadows = [];

    switch (widget.type) {
      case BLKWDSButtonTypeEnhanced.primary:
        backgroundColor = widget.customColor ?? BLKWDSColors.primaryButtonBackground;
        textColor = widget.customTextColor ?? BLKWDSColors.primaryButtonText;
        borderColor = null;
        gradient = widget.useGradient ? BLKWDSGradients.primaryButtonGradient : null;
        shadows = widget.hasShadow ? BLKWDSShadows.getShadow(BLKWDSShadows.level2) : [];
        break;
      case BLKWDSButtonTypeEnhanced.secondary:
        backgroundColor = BLKWDSColors.transparent;
        textColor = widget.customTextColor ?? BLKWDSColors.slateGrey;
        borderColor = widget.customColor ?? BLKWDSColors.secondaryButtonBorder;
        gradient = widget.useGradient ? BLKWDSGradients.secondaryButtonGradient : null;
        shadows = widget.hasShadow ? BLKWDSShadows.getShadow(BLKWDSShadows.level1) : [];
        break;
      case BLKWDSButtonTypeEnhanced.danger:
        backgroundColor = widget.customColor ?? BLKWDSColors.errorRed;
        textColor = widget.customTextColor ?? BLKWDSColors.white;
        borderColor = null;
        gradient = widget.useGradient ? BLKWDSGradients.dangerButtonGradient : null;
        shadows = widget.hasShadow ? BLKWDSShadows.getErrorShadow() : [];
        break;
      case BLKWDSButtonTypeEnhanced.success:
        backgroundColor = widget.customColor ?? BLKWDSColors.electricMint;
        textColor = widget.customTextColor ?? BLKWDSColors.deepBlack;
        borderColor = null;
        gradient = widget.useGradient ? BLKWDSGradients.successGradient : null;
        shadows = widget.hasShadow ? BLKWDSShadows.getSuccessShadow() : [];
        break;
      case BLKWDSButtonTypeEnhanced.warning:
        backgroundColor = widget.customColor ?? BLKWDSColors.mustardOrange;
        textColor = widget.customTextColor ?? BLKWDSColors.deepBlack;
        borderColor = null;
        gradient = widget.useGradient ? BLKWDSGradients.warningGradient : null;
        shadows = widget.hasShadow ? BLKWDSShadows.getWarningShadow() : [];
        break;
      case BLKWDSButtonTypeEnhanced.text:
        backgroundColor = BLKWDSColors.transparent;
        textColor = widget.customTextColor ?? BLKWDSColors.electricMint;
        borderColor = BLKWDSColors.transparent;
        gradient = null;
        shadows = [];
        break;
      case BLKWDSButtonTypeEnhanced.icon:
        backgroundColor = widget.customColor ?? BLKWDSColors.transparent;
        textColor = widget.customTextColor ?? BLKWDSColors.electricMint;
        borderColor = widget.type == BLKWDSButtonTypeEnhanced.secondary ? textColor : null;
        gradient = null;
        shadows = widget.hasShadow ? BLKWDSShadows.getShadow(BLKWDSShadows.level1) : [];
        break;
    }

    // Apply disabled styling if needed
    if (widget.isDisabled) {
      backgroundColor = backgroundColor.withValues(alpha: 128); // 0.5 * 255 = 128
      textColor = textColor.withValues(alpha: 179); // 0.7 * 255 = 179
      if (borderColor != null) {
        borderColor = borderColor.withValues(alpha: 128); // 0.5 * 255 = 128
      }
      gradient = null;
      shadows = [];
    }

    // Override with custom gradient if provided
    if (widget.customGradient != null) {
      gradient = widget.customGradient;
    }

    // Apply hover effects if enabled
    if (_isHovered && widget.animateOnHover && !widget.isDisabled) {
      shadows = widget.hasShadow ? BLKWDSShadows.getHoverShadow() : [];
    }

    // Apply pressed effects
    if (_isPressed && widget.onPressed != null && !widget.isDisabled) {
      shadows = widget.hasShadow ? BLKWDSShadows.getActiveShadow() : [];
    }

    // Determine padding based on size
    final double horizontalPadding = widget.padding != null
        ? 0
        : (widget.type == BLKWDSButtonTypeEnhanced.icon
            ? (widget.isSmall ? 8.0 : 12.0)
            : (widget.isSmall
                ? BLKWDSConstants.buttonHorizontalPadding / 1.5
                : BLKWDSConstants.buttonHorizontalPadding));

    final double verticalPadding = widget.padding != null
        ? 0
        : (widget.type == BLKWDSButtonTypeEnhanced.icon
            ? (widget.isSmall ? 8.0 : 12.0)
            : (widget.isSmall
                ? BLKWDSConstants.buttonVerticalPadding / 1.5
                : BLKWDSConstants.buttonVerticalPadding));

    // Create button content
    Widget buttonContent;

    if (widget.customChild != null) {
      buttonContent = widget.customChild!;
    } else if (widget.type == BLKWDSButtonTypeEnhanced.icon) {
      buttonContent = Icon(
        widget.icon!,
        size: widget.isSmall ? 16 : 20,
        color: textColor
      );
    } else {
      buttonContent = Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon!,
              color: textColor,
              size: widget.isSmall ? 16 : 20,
            ),
            SizedBox(width: BLKWDSConstants.spacingSmall),
          ],
          Text(
            widget.label,
            style: widget.isSmall
                ? BLKWDSTypography.labelMedium.copyWith(color: textColor)
                : BLKWDSTypography.labelLarge.copyWith(color: textColor),
          ),
        ],
      );
    }

    // Add loading indicator if button is loading
    if (widget.isLoading) {
      buttonContent = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.0,
            child: buttonContent,
          ),
          SizedBox(
            width: widget.isSmall ? 16 : 20,
            height: widget.isSmall ? 16 : 20,
            child: BLKWDSLoadingSpinner(
              size: widget.isSmall ? 16 : 20,
              color: textColor,
              strokeWidth: 2.0,
            ),
          ),
        ],
      );
    }

    // Create the button with appropriate styling
    return AnimatedContainer(
      duration: BLKWDSAnimations.short,
      curve: BLKWDSAnimations.standard,
      width: widget.width ?? (widget.isFullWidth ? double.infinity : null),
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(BLKWDSConstants.buttonBorderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
        boxShadow: shadows,
      ),
      transform: Matrix4.identity()
        ..scale(_isHovered && widget.animateOnHover && !widget.isDisabled ? 1.02 : 1.0)
        ..scale(_isPressed && widget.onPressed != null && !widget.isDisabled ? 0.98 : 1.0),
      child: Material(
        color: BLKWDSColors.transparent,
        child: InkWell(
          onTap: widget.isDisabled ? null : widget.onPressed,
          onHover: (isHovered) {
            if (mounted && widget.animateOnHover) {
              setState(() {
                _isHovered = isHovered;
              });
            }
          },
          onTapDown: (_) {
            if (mounted) {
              setState(() {
                _isPressed = true;
              });
            }
          },
          onTapUp: (_) {
            if (mounted) {
              setState(() {
                _isPressed = false;
              });
            }
          },
          onTapCancel: () {
            if (mounted) {
              setState(() {
                _isPressed = false;
              });
            }
          },
          splashColor: widget.type == BLKWDSButtonTypeEnhanced.text
              ? BLKWDSColors.transparent
              : textColor.withValues(alpha: 30),
          highlightColor: widget.type == BLKWDSButtonTypeEnhanced.text
              ? BLKWDSColors.transparent
              : textColor.withValues(alpha: 20),
          borderRadius: BorderRadius.circular(BLKWDSConstants.buttonBorderRadius),
          child: Padding(
            padding: widget.padding ?? EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Center(child: buttonContent),
          ),
        ),
      ),
    );
  }
}
