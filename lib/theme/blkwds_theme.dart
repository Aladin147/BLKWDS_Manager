import 'package:flutter/material.dart';
import 'blkwds_colors.dart';
import 'blkwds_typography.dart';
import 'blkwds_constants.dart';

/// BLKWDS Manager Theme
/// Combines colors, typography, and constants into a cohesive theme
class BLKWDSTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      // Color Scheme
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: BLKWDSColors.mustardOrange,
        onPrimary: BLKWDSColors.deepBlack,
        secondary: BLKWDSColors.accentTeal,
        onSecondary: BLKWDSColors.deepBlack,
        error: BLKWDSColors.alertCoral,
        onError: BLKWDSColors.white,
        background: BLKWDSColors.blkwdsGreen,
        onBackground: BLKWDSColors.white,
        surface: BLKWDSColors.white,
        onSurface: BLKWDSColors.deepBlack,
      ),
      
      // Text Theme
      textTheme: BLKWDSTypography.googleFontsTextTheme,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: BLKWDSColors.blkwdsGreen,
        foregroundColor: BLKWDSColors.white,
        elevation: 0,
        titleTextStyle: BLKWDSTypography.titleLarge.copyWith(
          color: BLKWDSColors.white,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: BLKWDSColors.cardBackground,
        elevation: BLKWDSConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BLKWDSColors.primaryButtonBackground,
          foregroundColor: BLKWDSColors.primaryButtonText,
          elevation: BLKWDSConstants.buttonElevation,
          padding: EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.buttonHorizontalPadding,
            vertical: BLKWDSConstants.buttonVerticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BLKWDSConstants.buttonBorderRadius),
          ),
          textStyle: BLKWDSTypography.labelLarge,
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BLKWDSColors.slateGrey,
          side: const BorderSide(color: BLKWDSColors.secondaryButtonBorder),
          padding: EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.buttonHorizontalPadding,
            vertical: BLKWDSConstants.buttonVerticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BLKWDSConstants.buttonBorderRadius),
          ),
          textStyle: BLKWDSTypography.labelLarge,
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BLKWDSColors.slateGrey,
          padding: EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.buttonHorizontalPadding,
            vertical: BLKWDSConstants.buttonVerticalPadding,
          ),
          textStyle: BLKWDSTypography.labelLarge,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BLKWDSColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          borderSide: const BorderSide(color: BLKWDSColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          borderSide: const BorderSide(color: BLKWDSColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          borderSide: const BorderSide(color: BLKWDSColors.mustardOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          borderSide: const BorderSide(color: BLKWDSColors.alertCoral),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: BLKWDSConstants.inputHorizontalPadding,
          vertical: BLKWDSConstants.inputVerticalPadding,
        ),
        labelStyle: BLKWDSTypography.bodyMedium,
        hintStyle: BLKWDSTypography.bodyMedium.copyWith(
          color: BLKWDSColors.slateGrey.withOpacity(0.6),
        ),
      ),
      
      // Scaffold Background Color
      scaffoldBackgroundColor: BLKWDSColors.blkwdsGreen,
      
      // Divider Color
      dividerColor: BLKWDSColors.slateGrey.withOpacity(0.2),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BLKWDSColors.deepBlack,
        contentTextStyle: BLKWDSTypography.bodyMedium.copyWith(
          color: BLKWDSColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
