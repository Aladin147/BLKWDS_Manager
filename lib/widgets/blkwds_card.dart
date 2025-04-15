import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_animations.dart';
import '../theme/blkwds_shadows.dart';
import '../theme/blkwds_gradients.dart';

/// Standardized card component for BLKWDS Manager
///
/// Provides consistent styling for all cards in the app with enhanced
/// visual effects including shadows, gradients, and animations
enum BLKWDSCardType {
  /// Standard card with default styling
  standard,

  /// Primary card with accent styling for emphasis
  primary,

  /// Secondary card with subtle styling
  secondary,

  /// Success card with positive styling
  success,

  /// Warning card with cautionary styling
  warning,

  /// Error card with negative styling
  error,
}

class BLKWDSCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double elevation;
  final BLKWDSCardType type;
  final bool useGradient;
  final Gradient? customGradient;
  final bool animateOnHover;
  final EdgeInsetsGeometry? margin;
  final bool hasShadow;
  final List<BoxShadow>? customShadow;
  final bool isLoading;

  const BLKWDSCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
    this.elevation = BLKWDSConstants.cardElevation,
    this.type = BLKWDSCardType.standard,
    this.useGradient = false,
    this.customGradient,
    this.animateOnHover = true,
    this.margin,
    this.hasShadow = true,
    this.customShadow,
    this.isLoading = false,
  });

  @override
  State<BLKWDSCard> createState() => _BLKWDSCardState();
}

class _BLKWDSCardState extends State<BLKWDSCard> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(BLKWDSCard oldWidget) {
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
    // Determine card styling based on type
    Color backgroundColor;
    Color? borderColor = widget.borderColor;
    Gradient? gradient;
    List<BoxShadow> shadows = [];

    // Set base styling based on card type
    switch (widget.type) {
      case BLKWDSCardType.standard:
        backgroundColor = BLKWDSColors.deepBlack;
        gradient = widget.useGradient ? BLKWDSGradients.cardGradient : null;
        shadows = widget.hasShadow ? BLKWDSShadows.getShadow(BLKWDSShadows.level2) : [];
        break;
      case BLKWDSCardType.primary:
        backgroundColor = BLKWDSColors.deepBlack;
        gradient = widget.useGradient ? BLKWDSGradients.primaryCardGradient : null;
        borderColor ??= BLKWDSColors.mustardOrange.withValues(alpha: 100);
        shadows = widget.hasShadow ? BLKWDSShadows.getColoredShadow(BLKWDSShadows.level3, BLKWDSColors.mustardOrange) : [];
        break;
      case BLKWDSCardType.secondary:
        backgroundColor = BLKWDSColors.deepBlack.withValues(alpha: 200);
        gradient = widget.useGradient ? BLKWDSGradients.secondaryButtonGradient : null;
        shadows = widget.hasShadow ? BLKWDSShadows.getShadow(BLKWDSShadows.level1) : [];
        break;
      case BLKWDSCardType.success:
        backgroundColor = BLKWDSColors.deepBlack;
        gradient = widget.useGradient ? BLKWDSGradients.cardGradient : null;
        borderColor ??= BLKWDSColors.electricMint.withValues(alpha: 100);
        shadows = widget.hasShadow ? BLKWDSShadows.getSuccessShadow() : [];
        break;
      case BLKWDSCardType.warning:
        backgroundColor = BLKWDSColors.deepBlack;
        gradient = widget.useGradient ? BLKWDSGradients.cardGradient : null;
        borderColor ??= BLKWDSColors.mustardOrange.withValues(alpha: 100);
        shadows = widget.hasShadow ? BLKWDSShadows.getWarningShadow() : [];
        break;
      case BLKWDSCardType.error:
        backgroundColor = BLKWDSColors.deepBlack;
        gradient = widget.useGradient ? BLKWDSGradients.cardGradient : null;
        borderColor ??= BLKWDSColors.alertCoral.withValues(alpha: 100);
        shadows = widget.hasShadow ? BLKWDSShadows.getErrorShadow() : [];
        break;
    }

    // Override with custom gradient if provided
    if (widget.customGradient != null) {
      gradient = widget.customGradient;
    }

    // Override with custom shadow if provided
    if (widget.customShadow != null) {
      shadows = widget.customShadow!;
    }

    // Apply hover effects if enabled
    if (_isHovered && widget.animateOnHover) {
      shadows = widget.hasShadow ? BLKWDSShadows.getHoverShadow() : [];
    }

    // Apply pressed effects
    if (_isPressed && widget.onTap != null) {
      shadows = widget.hasShadow ? BLKWDSShadows.getActiveShadow() : [];
    }

    // Create the card content
    final cardContent = Padding(
      padding: widget.padding ?? const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: widget.isLoading
          ? Stack(
              children: [
                Opacity(
                  opacity: 0.6,
                  child: widget.child,
                ),
                Positioned.fill(
                  child: Center(
                    child: BLKWDSLoadingSpinner(
                      color: _getLoadingColor(),
                    ),
                  ),
                ),
              ],
            )
          : widget.child,
    );

    // Create the card with appropriate styling
    return AnimatedContainer(
      duration: BLKWDSAnimations.short,
      curve: BLKWDSAnimations.standard,
      margin: widget.margin ?? const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.0)
            : null,
        boxShadow: shadows,
      ),
      transform: Matrix4.identity()
        ..scale(_isHovered && widget.animateOnHover ? 1.01 : 1.0)
        ..scale(_isPressed && widget.onTap != null ? 0.98 : 1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        child: Material(
          color: Colors.transparent,
          child: widget.onTap != null
              ? MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    onTap: widget.onTap,
                    child: cardContent,
                  ),
                )
              : cardContent,
        ),
      ),
    );
  }

  // Helper method to determine loading spinner color based on card type
  Color _getLoadingColor() {
    switch (widget.type) {
      case BLKWDSCardType.standard:
      case BLKWDSCardType.secondary:
        return BLKWDSColors.electricMint;
      case BLKWDSCardType.primary:
        return BLKWDSColors.mustardOrange;
      case BLKWDSCardType.success:
        return BLKWDSColors.electricMint;
      case BLKWDSCardType.warning:
        return BLKWDSColors.mustardOrange;
      case BLKWDSCardType.error:
        return BLKWDSColors.alertCoral;
    }
  }
}
