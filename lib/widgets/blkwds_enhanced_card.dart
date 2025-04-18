import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_style_enhancer.dart';

/// Enhanced Card Types
enum BLKWDSEnhancedCardType {
  standard,
  primary,
  secondary,
  success,
  warning,
  error,
}

/// BLKWDSEnhancedCard
/// An enhanced card widget with consistent styling and animations
class BLKWDSEnhancedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BLKWDSEnhancedCardType type;
  final bool isElevated;
  final bool useGradient;
  final bool animateOnHover;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  const BLKWDSEnhancedCard({
    super.key,
    required this.child,
    this.padding,
    this.type = BLKWDSEnhancedCardType.standard,
    this.isElevated = true,
    this.useGradient = false,
    this.animateOnHover = false,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<BLKWDSEnhancedCard> createState() => _BLKWDSEnhancedCardState();
}

class _BLKWDSEnhancedCardState extends State<BLKWDSEnhancedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Determine card styling based on type
    final isPrimary = widget.type == BLKWDSEnhancedCardType.primary;

    // Determine background color based on type
    Color backgroundColor = widget.backgroundColor ?? _getBackgroundColor();

    // Determine border if needed
    Border? border;
    if (widget.borderColor != null) {
      border = Border.all(
        color: widget.borderColor!,
        width: 1.5,
      );
    }

    // Create base card
    Widget card = Container(
      width: widget.width,
      height: widget.height,
      constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
      decoration: BLKWDSStyleEnhancer.enhanceCard(
        backgroundColor: backgroundColor,
        borderRadius: widget.borderRadius,
        border: border,
        isPrimary: isPrimary,
        isElevated: widget.isElevated,
        useGradient: widget.useGradient,
      ),
      padding: widget.padding ?? EdgeInsets.all(BLKWDSConstants.cardPaddingMedium),
      child: widget.child,
    );

    // Add hover animation if requested
    if (widget.animateOnHover) {
      card = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: BLKWDSConstants.animationDurationShort,
          child: AnimatedContainer(
            duration: BLKWDSConstants.animationDurationShort,
            constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
            width: widget.width,
            height: widget.height,
            decoration: BLKWDSStyleEnhancer.enhanceCard(
              backgroundColor: backgroundColor,
              borderRadius: widget.borderRadius,
              border: border,
              isPrimary: isPrimary,
              isElevated: _isHovered ? true : widget.isElevated,
              useGradient: widget.useGradient,
            ),
            padding: widget.padding ?? EdgeInsets.all(BLKWDSConstants.cardPaddingMedium),
            child: widget.child,
          ),
        ),
      );
    }

    // Add tap functionality if provided
    if (widget.onTap != null) {
      card = GestureDetector(
        onTap: widget.onTap,
        child: card,
      );
    }

    return card;
  }

  // Helper method to determine background color based on card type
  Color _getBackgroundColor() {
    switch (widget.type) {
      case BLKWDSEnhancedCardType.standard:
        return BLKWDSColors.backgroundMedium;
      case BLKWDSEnhancedCardType.primary:
        return BLKWDSColors.blkwdsGreen;
      case BLKWDSEnhancedCardType.secondary:
        return BLKWDSColors.backgroundLight;
      case BLKWDSEnhancedCardType.success:
        return BLKWDSColors.successGreen;
      case BLKWDSEnhancedCardType.warning:
        return BLKWDSColors.warningAmber;
      case BLKWDSEnhancedCardType.error:
        return BLKWDSColors.errorRed;
    }
  }
}
