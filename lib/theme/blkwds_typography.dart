import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blkwds_colors.dart';
import 'blkwds_constants.dart';

/// BLKWDS Manager Typography
/// Based on the visual guidelines document
class BLKWDSTypography {
  // Font Families
  static const String headingFontFamily = 'Sora';
  static const String bodyFontFamily = 'Inter';
  static const String codeFontFamily = 'JetBrainsMono';

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Text Styles
  // Display Styles - For large headers, usually at the top of screens
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 36,
    fontWeight: bold,
    color: BLKWDSColors.white,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 32,
    fontWeight: bold,
    color: BLKWDSColors.white,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get displaySmall => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 28,
    fontWeight: bold,
    color: BLKWDSColors.white,
    letterSpacing: -0.25,
    height: 1.2,
  );

  // Headline Styles - For section headers
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 26,
    fontWeight: bold,
    color: BLKWDSColors.white,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    color: BLKWDSColors.white,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 22,
    fontWeight: semiBold,
    color: BLKWDSColors.white,
    letterSpacing: -0.25,
    height: 1.3,
  );

  // Title Styles - For card titles and smaller section headers
  static TextStyle get titleLarge => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 20,
    fontWeight: semiBold,
    color: BLKWDSColors.white,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 18,
    fontWeight: semiBold,
    color: BLKWDSColors.white,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    color: BLKWDSColors.white,
    letterSpacing: 0,
    height: 1.4,
  );

  // Body Styles - For regular text content
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    fontWeight: regular,
    color: BLKWDSColors.white,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: regular,
    color: BLKWDSColors.white,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: regular,
    color: BLKWDSColors.white,
    letterSpacing: 0.15,
    height: 1.5,
  );

  // Label Styles - For buttons, form fields, and other interactive elements
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    fontWeight: medium,
    color: BLKWDSColors.white,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: medium,
    color: BLKWDSColors.white,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: medium,
    color: BLKWDSColors.white,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Code Text - For monospace text like code snippets or logs
  static TextStyle get codeText => const TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 14,
    fontWeight: regular,
    color: BLKWDSColors.white,
    letterSpacing: 0,
    height: 1.5,
  );

  // Caption - For very small text like timestamps, credits, etc.
  static TextStyle get caption => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 11,
    fontWeight: regular,
    color: BLKWDSColors.slateGrey,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // Overline - For small uppercase text above other content
  static TextStyle get overline => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 10,
    fontWeight: medium,
    color: BLKWDSColors.slateGrey,
    letterSpacing: 1.0,
    height: 1.4,
    textBaseline: TextBaseline.alphabetic,
  );

  // Text Theme
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  // Google Fonts Fallback (for development until custom fonts are properly set up)
  static TextTheme get googleFontsTextTheme => TextTheme(
    displayLarge: GoogleFonts.sora(
      fontSize: 36,
      fontWeight: bold,
      color: BLKWDSColors.white,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displayMedium: GoogleFonts.sora(
      fontSize: 32,
      fontWeight: bold,
      color: BLKWDSColors.white,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displaySmall: GoogleFonts.sora(
      fontSize: 28,
      fontWeight: bold,
      color: BLKWDSColors.white,
      letterSpacing: -0.25,
      height: 1.2,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 26,
      fontWeight: bold,
      color: BLKWDSColors.white,
      letterSpacing: -0.25,
      height: 1.3,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 24,
      fontWeight: semiBold,
      color: BLKWDSColors.white,
      letterSpacing: -0.25,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: 22,
      fontWeight: semiBold,
      color: BLKWDSColors.white,
      letterSpacing: -0.25,
      height: 1.3,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 20,
      fontWeight: semiBold,
      color: BLKWDSColors.white,
      letterSpacing: 0,
      height: 1.4,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: semiBold,
      color: BLKWDSColors.white,
      letterSpacing: 0,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: semiBold,
      color: BLKWDSColors.white,
      letterSpacing: 0,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: regular,
      color: BLKWDSColors.white,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: regular,
      color: BLKWDSColors.white,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: regular,
      color: BLKWDSColors.white,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: medium,
      color: BLKWDSColors.white,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: medium,
      color: BLKWDSColors.white,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: medium,
      color: BLKWDSColors.white,
      letterSpacing: 0.1,
      height: 1.4,
    ),
  );
}
