import 'package:flutter/material.dart';
import 'blkwds_colors.dart';
import 'blkwds_typography.dart';
import 'blkwds_constants.dart';

/// BLKWDS Manager Theme
/// Provides a dark theme for the app
class BLKWDSTheme {
  // App Theme (Dark Mode Only)
  static ThemeData get theme {
    return ThemeData.dark().copyWith(
      // Color Scheme
      colorScheme: const ColorScheme.dark().copyWith(
        primary: BLKWDSColors.mustardOrange,
        onPrimary: BLKWDSColors.deepBlack,
        secondary: BLKWDSColors.accentTeal,
        onSecondary: BLKWDSColors.deepBlack,
        error: BLKWDSColors.alertCoral,
        onError: BLKWDSColors.white,
        surface: BLKWDSColors.deepBlack,
        onSurface: BLKWDSColors.white,
      ),

      // Text Theme
      textTheme: BLKWDSTypography.googleFontsTextTheme.apply(
        bodyColor: BLKWDSColors.white,
        displayColor: BLKWDSColors.white,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: BLKWDSColors.deepBlack,
        foregroundColor: BLKWDSColors.white,
        elevation: 0,
        titleTextStyle: BLKWDSTypography.titleLarge.copyWith(
          color: BLKWDSColors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: BLKWDSColors.deepBlack.withValues(alpha: 200),
        elevation: BLKWDSConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BLKWDSColors.mustardOrange,
          foregroundColor: BLKWDSColors.deepBlack,
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
          foregroundColor: BLKWDSColors.white,
          side: const BorderSide(color: BLKWDSColors.slateGrey),
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
          foregroundColor: BLKWDSColors.white,
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
        fillColor: BLKWDSColors.deepBlack.withValues(alpha: 200),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          borderSide: const BorderSide(color: BLKWDSColors.slateGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          borderSide: const BorderSide(color: BLKWDSColors.slateGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          borderSide: const BorderSide(color: BLKWDSColors.mustardOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          borderSide: const BorderSide(color: BLKWDSColors.alertCoral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          borderSide: const BorderSide(color: BLKWDSColors.alertCoral, width: 2),
        ),
        labelStyle: BLKWDSTypography.labelMedium.copyWith(
          color: BLKWDSColors.white,
        ),
        hintStyle: BLKWDSTypography.bodyMedium.copyWith(
          color: BLKWDSColors.slateGrey,
        ),
        errorStyle: BLKWDSTypography.labelSmall.copyWith(
          color: BLKWDSColors.alertCoral,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: BLKWDSConstants.inputHorizontalPadding,
          vertical: BLKWDSConstants.inputVerticalPadding,
        ),
      ),

      // Scaffold Background Color
      scaffoldBackgroundColor: BLKWDSColors.deepBlack,

      // Divider Color
      dividerColor: BLKWDSColors.slateGrey.withValues(alpha: 50),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BLKWDSColors.slateGrey,
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
