import 'package:flutter/material.dart';
import 'blkwds_colors.dart';
import 'blkwds_constants.dart';
import 'blkwds_shadows.dart';

/// BLKWDSStyleEnhancer
/// A utility class for enhancing UI elements with consistent styling
class BLKWDSStyleEnhancer {
  /// Enhance a container with consistent styling
  static BoxDecoration enhanceContainer({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    bool isPrimary = false,
    bool isElevated = true,
    bool useGradient = false,
  }) {
    // Set default values
    backgroundColor ??= isPrimary
        ? BLKWDSColors.blkwdsGreen
        : BLKWDSColors.backgroundMedium;

    borderRadius ??= BorderRadius.circular(BLKWDSConstants.borderRadiusMedium);

    // Determine shadow level based on elevation
    final shadowLevel = isElevated
        ? isPrimary ? BLKWDSShadows.level3 : BLKWDSShadows.level2
        : BLKWDSShadows.level0;

    // Get appropriate shadows
    boxShadow ??= isPrimary
        ? BLKWDSShadows.getColoredShadow(shadowLevel, BLKWDSColors.blkwdsGreen)
        : BLKWDSShadows.getShadow(shadowLevel);

    // Create gradient if requested
    if (useGradient) {
      if (isPrimary) {
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withValues(red: backgroundColor.r.round() + 20, blue: backgroundColor.b.round() + 10),
          ],
        );
      } else {
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BLKWDSColors.backgroundMedium,
            BLKWDSColors.backgroundLight,
          ],
        );
      }
    }

    return BoxDecoration(
      color: gradient != null ? null : backgroundColor,
      borderRadius: borderRadius,
      border: border,
      boxShadow: boxShadow,
      gradient: gradient,
    );
  }

  /// Enhance a button with consistent styling
  static ButtonStyle enhanceButton({
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    bool isPrimary = true,
    bool isElevated = true,
  }) {
    // Set default values
    backgroundColor ??= isPrimary
        ? BLKWDSColors.blkwdsGreen
        : BLKWDSColors.backgroundMedium;

    foregroundColor ??= isPrimary
        ? BLKWDSColors.deepBlack
        : BLKWDSColors.white;

    borderRadius ??= BorderRadius.circular(BLKWDSConstants.buttonBorderRadius);

    padding ??= EdgeInsets.symmetric(
      horizontal: BLKWDSConstants.buttonHorizontalPaddingMedium,
      vertical: BLKWDSConstants.buttonVerticalPaddingMedium,
    );

    // Determine elevation based on settings
    final elevation = isElevated
        ? isPrimary ? BLKWDSConstants.buttonFocusedElevation : BLKWDSConstants.buttonElevation
        : 0.0;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return backgroundColor!.withAlpha(BLKWDSColors.alphaLow);
        }
        if (states.contains(WidgetState.pressed)) {
          return backgroundColor!.darken(10);
        }
        if (states.contains(WidgetState.hovered)) {
          return backgroundColor!.brighten(10);
        }
        return backgroundColor!;
      }),
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      elevation: WidgetStateProperty.all(elevation),
      padding: WidgetStateProperty.all(padding),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: borderRadius,
      )),
      overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return foregroundColor!.withAlpha(BLKWDSColors.alphaVeryLow);
        }
        if (states.contains(WidgetState.hovered)) {
          return foregroundColor!.withAlpha(BLKWDSColors.alphaVeryLow);
        }
        return Colors.transparent;
      }),
      animationDuration: BLKWDSConstants.animationDurationShort,
    );
  }

  /// Enhance a card with consistent styling
  static BoxDecoration enhanceCard({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    bool isPrimary = false,
    bool isElevated = true,
    bool useGradient = false,
  }) {
    return enhanceContainer(
      backgroundColor: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(BLKWDSConstants.cardBorderRadius),
      border: border,
      boxShadow: boxShadow,
      gradient: gradient,
      isPrimary: isPrimary,
      isElevated: isElevated,
      useGradient: useGradient,
    );
  }

  /// Enhance text with consistent styling
  static TextStyle enhanceText(
    TextStyle baseStyle, {
    Color? color,
    double? letterSpacing,
    double? height,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    bool isPrimary = false,
  }) {
    color ??= isPrimary ? BLKWDSColors.blkwdsGreen : null;

    return baseStyle.copyWith(
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontWeight: fontWeight,
      decoration: decoration,
    );
  }

  /// Apply consistent animation to a widget
  static Widget animateWidget(
    Widget child, {
    bool onHover = true,
    bool onTap = true,
    double scale = 0.98,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        bool isPressed = false;

        return GestureDetector(
          onTapDown: onTap ? (_) => setState(() => isPressed = true) : null,
          onTapUp: onTap ? (_) => setState(() => isPressed = false) : null,
          onTapCancel: onTap ? () => setState(() => isPressed = false) : null,
          child: MouseRegion(
            onEnter: onHover ? (_) => setState(() => isHovered = true) : null,
            onExit: onHover ? (_) => setState(() => isHovered = false) : null,
            child: AnimatedScale(
              scale: (isHovered || isPressed) ? scale : 1.0,
              duration: duration,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
