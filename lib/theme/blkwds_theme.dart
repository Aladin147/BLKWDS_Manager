import 'package:flutter/material.dart';
import 'blkwds_colors.dart';
import 'blkwds_typography.dart';
import 'blkwds_constants_enhanced.dart';

/// BLKWDS Manager Theme
/// Provides a dark theme for the app with enhanced visual appeal and readability
class BLKWDSTheme {
  // App Theme (Dark Mode Only)
  static ThemeData get theme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      // Color Scheme
      colorScheme: const ColorScheme.dark().copyWith(
        primary: BLKWDSColors.mustardOrange,
        onPrimary: BLKWDSColors.deepBlack,
        secondary: BLKWDSColors.accentTeal,
        onSecondary: BLKWDSColors.deepBlack,
        error: BLKWDSColors.errorRed,
        onError: BLKWDSColors.white,
        surface: BLKWDSColors.backgroundDark,
        onSurface: BLKWDSColors.white,
        surfaceTint: BLKWDSColors.backgroundMedium,
      ),

      // Text Theme
      textTheme: BLKWDSTypography.googleFontsTextTheme.apply(
        bodyColor: BLKWDSColors.white,
        displayColor: BLKWDSColors.white,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: BLKWDSColors.backgroundDark,
        foregroundColor: BLKWDSColors.white,
        elevation: BLKWDSConstants.appBarElevationSmall,
        titleTextStyle: BLKWDSTypography.titleLarge.copyWith(
          color: BLKWDSColors.white,
        ),
        shadowColor: BLKWDSColors.deepBlack.withValues(alpha: 100),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: BLKWDSColors.backgroundMedium,
        elevation: BLKWDSConstants.cardElevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.cardBorderRadius),
        ),
        shadowColor: BLKWDSColors.deepBlack.withValues(alpha: 100),
        margin: const EdgeInsets.all(BLKWDSConstants.spacingXSmall),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BLKWDSColors.mustardOrange,
          foregroundColor: BLKWDSColors.deepBlack,
          elevation: BLKWDSConstants.buttonElevation,
          shadowColor: BLKWDSColors.mustardOrange.withValues(alpha: 60),
          padding: EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.buttonHorizontalPaddingMedium,
            vertical: BLKWDSConstants.buttonVerticalPaddingMedium,
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
          side: BorderSide(color: BLKWDSColors.border),
          backgroundColor: BLKWDSColors.backgroundLight,
          padding: EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.buttonHorizontalPaddingMedium,
            vertical: BLKWDSConstants.buttonVerticalPaddingMedium,
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
          foregroundColor: BLKWDSColors.accentTeal,
          padding: EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
            vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
          ),
          textStyle: BLKWDSTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadiusSmall),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BLKWDSColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
          borderSide: BorderSide(color: BLKWDSColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
          borderSide: BorderSide(color: BLKWDSColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
          borderSide: BorderSide(color: BLKWDSColors.accentTeal, width: BLKWDSConstants.inputFocusBorderWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
          borderSide: BorderSide(color: BLKWDSColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
          borderSide: BorderSide(color: BLKWDSColors.errorRed, width: BLKWDSConstants.inputFocusBorderWidth),
        ),
        labelStyle: BLKWDSTypography.labelMedium.copyWith(
          color: BLKWDSColors.textSecondary,
        ),
        hintStyle: BLKWDSTypography.bodyMedium.copyWith(
          color: BLKWDSColors.textHint,
        ),
        errorStyle: BLKWDSTypography.bodySmall.copyWith(
          color: BLKWDSColors.errorRed,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: BLKWDSConstants.inputHorizontalPadding,
          vertical: BLKWDSConstants.inputVerticalPadding,
        ),
        isDense: false,
      ),

      // Scaffold Background Color
      scaffoldBackgroundColor: BLKWDSColors.backgroundDark,

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: BLKWDSColors.divider,
        thickness: BLKWDSConstants.dividerThicknessSmall,
        space: BLKWDSConstants.spacingMedium,
        indent: BLKWDSConstants.dividerIndent,
        endIndent: BLKWDSConstants.dividerEndIndent,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BLKWDSColors.backgroundLight,
        contentTextStyle: BLKWDSTypography.bodyMedium.copyWith(
          color: BLKWDSColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.snackbarBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4.0,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: BLKWDSColors.accentTeal,
        unselectedLabelColor: BLKWDSColors.textSecondary,
        indicatorColor: BLKWDSColors.accentTeal,
        labelStyle: BLKWDSTypography.labelMedium,
        unselectedLabelStyle: BLKWDSTypography.labelMedium,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: BLKWDSColors.backgroundMedium,
        elevation: BLKWDSConstants.cardElevationLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.dialogBorderRadius),
        ),
        titleTextStyle: BLKWDSTypography.titleMedium,
        contentTextStyle: BLKWDSTypography.bodyMedium,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BLKWDSColors.backgroundDark,
        selectedItemColor: BLKWDSColors.accentTeal,
        unselectedItemColor: BLKWDSColors.textSecondary,
        selectedLabelStyle: BLKWDSTypography.labelSmall,
        unselectedLabelStyle: BLKWDSTypography.labelSmall,
        elevation: BLKWDSConstants.bottomNavElevation,
        type: BottomNavigationBarType.fixed,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: BLKWDSColors.backgroundLight,
          borderRadius: BorderRadius.circular(BLKWDSConstants.tooltipBorderRadius),
        ),
        textStyle: BLKWDSTypography.bodySmall.copyWith(
          color: BLKWDSColors.white,
        ),
        padding: EdgeInsets.all(BLKWDSConstants.tooltipPadding),
      ),

      // Misc
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
