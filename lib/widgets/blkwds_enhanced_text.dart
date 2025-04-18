import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_style_enhancer.dart';
import '../theme/blkwds_typography.dart';

/// BLKWDSEnhancedText
/// An enhanced text widget with consistent styling
class BLKWDSEnhancedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool isPrimary;
  final bool isBold;
  final bool isItalic;
  final bool hasUnderline;
  final Color? color;
  final double? letterSpacing;
  final double? height;

  const BLKWDSEnhancedText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isPrimary = false,
    this.isBold = false,
    this.isItalic = false,
    this.hasUnderline = false,
    this.color,
    this.letterSpacing,
    this.height,
  });

  /// Factory constructor for display large text
  factory BLKWDSEnhancedText.displayLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.displayLarge,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Factory constructor for display medium text
  factory BLKWDSEnhancedText.displayMedium(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.displayMedium,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Factory constructor for heading large text
  factory BLKWDSEnhancedText.headingLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.headlineLarge,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Factory constructor for heading medium text
  factory BLKWDSEnhancedText.headingMedium(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.headlineMedium,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Factory constructor for title large text
  factory BLKWDSEnhancedText.titleLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.titleLarge,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Factory constructor for body large text
  factory BLKWDSEnhancedText.bodyLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.bodyLarge,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Factory constructor for body small text
  factory BLKWDSEnhancedText.bodySmall(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.bodySmall,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Factory constructor for body medium text
  factory BLKWDSEnhancedText.bodyMedium(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.bodyMedium,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Factory constructor for label medium text
  factory BLKWDSEnhancedText.labelMedium(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.labelMedium,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Factory constructor for label large text
  factory BLKWDSEnhancedText.labelLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isPrimary = false,
    bool isBold = false,
    bool isItalic = false,
    bool hasUnderline = false,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return BLKWDSEnhancedText(
      key: key,
      text: text,
      style: BLKWDSTypography.labelLarge,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      isPrimary: isPrimary,
      isBold: isBold,
      isItalic: isItalic,
      hasUnderline: hasUnderline,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Helper method to get the label medium style
  static TextStyle getLabelMediumStyle() {
    return BLKWDSTypography.labelMedium;
  }

  /// Helper method to get the body medium style
  static TextStyle getBodyMediumStyle() {
    return BLKWDSTypography.bodyMedium;
  }

  /// Helper method to get the body small style
  static TextStyle getBodySmallStyle() {
    return BLKWDSTypography.bodySmall;
  }

  @override
  Widget build(BuildContext context) {
    // Determine text style
    TextStyle textStyle = style ?? BLKWDSTypography.bodyMedium;

    // Apply enhancements
    textStyle = BLKWDSStyleEnhancer.enhanceText(
      textStyle,
      color: color ?? (isPrimary ? BLKWDSColors.blkwdsGreen : null),
      letterSpacing: letterSpacing,
      height: height,
      fontWeight: isBold ? FontWeight.bold : null,
      decoration: hasUnderline ? TextDecoration.underline : null,
      isPrimary: isPrimary,
    );

    // Apply italic if requested
    if (isItalic) {
      textStyle = textStyle.copyWith(
        fontStyle: FontStyle.italic,
      );
    }

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
