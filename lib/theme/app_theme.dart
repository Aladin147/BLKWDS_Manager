import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// AppTheme
/// Defines the application theme
class AppTheme {
  /// Primary color
  static const Color primaryColor = Color(0xFF2196F3);

  /// Secondary color
  static const Color secondaryColor = Color(0xFF4CAF50);

  /// Accent color
  static const Color accentColor = Color(0xFFFFC107);

  /// Background color
  static const Color backgroundColor = Color(0xFF121212);

  /// Surface color
  static const Color surfaceColor = Color(0xFF1E1E1E);

  /// Error color
  static const Color errorColor = Color(0xFFCF6679);

  /// Success color
  static const Color successColor = Color(0xFF4CAF50);

  /// Warning color
  static const Color warningColor = Color(0xFFFFC107);

  /// Info color
  static const Color infoColor = Color(0xFF2196F3);

  /// Danger color
  static const Color dangerColor = Color(0xFFE53935);

  /// Text color
  static const Color textColor = Color(0xFFFFFFFF);

  /// Secondary text color
  static const Color secondaryTextColor = Color(0xFFB0B0B0);

  /// Disabled text color
  static const Color disabledTextColor = Color(0xFF757575);

  /// Divider color
  static const Color dividerColor = Color(0xFF424242);

  /// Card color
  static const Color cardColor = Color(0xFF2D2D2D);

  /// Dialog color
  static const Color dialogColor = Color(0xFF323232);

  /// Elevation overlay color
  static const Color elevationOverlayColor = Color(0x1FFFFFFF);

  /// Shadow color
  static const Color shadowColor = Color(0x33000000);

  /// Get the theme data
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        // Using surfaceContainerHighest instead of deprecated background
        surfaceContainerHighest: backgroundColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      // dialogBackgroundColor is deprecated, using dialogTheme.backgroundColor instead
      dividerColor: dividerColor,
      shadowColor: shadowColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w300,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w300,
          color: textColor,
        ),
        displaySmall: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: secondaryTextColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(
          color: secondaryTextColor,
        ),
        hintStyle: const TextStyle(
          color: disabledTextColor,
        ),
        errorStyle: const TextStyle(
          color: errorColor,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledTextColor;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return dividerColor;
        }),
        checkColor: WidgetStateProperty.all(textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledTextColor;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return dividerColor;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledTextColor;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return textColor;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledTextColor.withOpacity(0.5); // TODO: Import ColorExtension from blkwds_colors.dart to use withValues
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5); // TODO: Import ColorExtension from blkwds_colors.dart to use withValues
          }
          return dividerColor;
        }),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: dialogColor, // Proper place for dialog background color
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: const TextStyle(
          color: textColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryTextColor,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: secondaryTextColor,
        indicatorColor: primaryColor,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        disabledColor: disabledTextColor,
        selectedColor: primaryColor,
        secondarySelectedColor: secondaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 0,
        ),
        labelStyle: const TextStyle(
          color: textColor,
        ),
        secondaryLabelStyle: const TextStyle(
          color: textColor,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(
          color: textColor,
        ),
      ),
    );
  }
}
