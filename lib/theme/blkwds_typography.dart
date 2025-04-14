import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blkwds_colors.dart';

/// BLKWDS Manager Typography
/// Based on the visual guidelines document
class BLKWDSTypography {
  // Font Families
  static const String headingFontFamily = 'Sora';
  static const String bodyFontFamily = 'Inter';
  static const String codeFontFamily = 'JetBrainsMono';
  
  // Text Styles
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.deepBlack,
  );
  
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.deepBlack,
  );
  
  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.deepBlack,
  );
  
  static TextStyle get titleLarge => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.deepBlack,
  );
  
  static TextStyle get titleMedium => const TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.deepBlack,
  );
  
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    color: BLKWDSColors.slateGrey,
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    color: BLKWDSColors.slateGrey,
  );
  
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.deepBlack,
  );
  
  static TextStyle get labelMedium => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.deepBlack,
  );
  
  static TextStyle get codeText => const TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 14,
    color: BLKWDSColors.deepBlack,
  );
  
  // Text Theme
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
  );
  
  // Google Fonts Fallback (for development until custom fonts are properly set up)
  static TextTheme get googleFontsTextTheme => TextTheme(
    displayLarge: GoogleFonts.sora(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: BLKWDSColors.deepBlack,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: BLKWDSColors.deepBlack,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: BLKWDSColors.deepBlack,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: BLKWDSColors.deepBlack,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: BLKWDSColors.deepBlack,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      color: BLKWDSColors.slateGrey,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      color: BLKWDSColors.slateGrey,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: BLKWDSColors.deepBlack,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: BLKWDSColors.deepBlack,
    ),
  );
}
