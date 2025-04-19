import 'package:flutter/material.dart';
import '../widgets/blkwds_button.dart';
import '../widgets/blkwds_card.dart';
import '../widgets/blkwds_enhanced_widgets.dart';

/// Helper class to assist with migrating from legacy widgets to enhanced widgets
class StyleMigrationHelper {
  /// Convert legacy BLKWDSButtonType to enhanced BLKWDSEnhancedButtonType
  static BLKWDSEnhancedButtonType convertButtonType(BLKWDSButtonType legacyType) {
    switch (legacyType) {
      case BLKWDSButtonType.primary:
        return BLKWDSEnhancedButtonType.primary;
      case BLKWDSButtonType.secondary:
        return BLKWDSEnhancedButtonType.secondary;
      case BLKWDSButtonType.danger:
        return BLKWDSEnhancedButtonType.error;
    }
  }

  /// Convert legacy BLKWDSCardType to enhanced BLKWDSEnhancedCardType
  static BLKWDSEnhancedCardType convertCardType(BLKWDSCardType legacyType) {
    switch (legacyType) {
      case BLKWDSCardType.standard:
        return BLKWDSEnhancedCardType.standard;
      case BLKWDSCardType.primary:
        return BLKWDSEnhancedCardType.primary;
      case BLKWDSCardType.secondary:
        return BLKWDSEnhancedCardType.secondary;
      case BLKWDSCardType.success:
        return BLKWDSEnhancedCardType.success;
      case BLKWDSCardType.warning:
        return BLKWDSEnhancedCardType.warning;
      case BLKWDSCardType.error:
        return BLKWDSEnhancedCardType.error;
    }
  }

  /// Create an enhanced button from legacy button parameters
  static Widget createEnhancedButton({
    required String label,
    VoidCallback? onPressed,
    BLKWDSButtonType type = BLKWDSButtonType.primary,
    IconData? icon,
    bool isFullWidth = false,
    bool isSmall = false,
    BLKWDSButtonSize? size,
    bool isDisabled = false,
    bool isLoading = false,
  }) {
    // Determine button size
    EdgeInsetsGeometry? padding;
    if (isSmall || size == BLKWDSButtonSize.small) {
      padding = const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      );
    } else if (size == BLKWDSButtonSize.large) {
      padding = const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      );
    }

    return BLKWDSEnhancedButton(
      label: label,
      onPressed: isDisabled ? null : onPressed,
      type: convertButtonType(type),
      icon: icon,
      padding: padding,
      isLoading: isLoading,
      width: isFullWidth ? double.infinity : null,
    );
  }

  /// Create an enhanced card from legacy card parameters
  static Widget createEnhancedCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? borderColor,
    VoidCallback? onTap,
    double elevation = 2.0,
    BLKWDSCardType type = BLKWDSCardType.standard,
    bool useGradient = false,
    Gradient? customGradient,
    bool animateOnHover = true,
    EdgeInsetsGeometry? margin,
    bool hasShadow = true,
    List<BoxShadow>? customShadow,
    bool isLoading = false,
  }) {
    return BLKWDSEnhancedCard(
      padding: padding,
      borderColor: borderColor,
      onTap: onTap,
      type: convertCardType(type),
      useGradient: useGradient,
      animateOnHover: animateOnHover,
      isElevated: hasShadow,
      child: isLoading
          ? Stack(
              children: [
                Opacity(
                  opacity: 0.6,
                  child: child,
                ),
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            )
          : child,
    );
  }

  /// Create enhanced text from a regular Text widget
  static Widget createEnhancedText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    Color? color,
  }) {
    return BLKWDSEnhancedText(
      text: text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      color: color,
    );
  }
}
