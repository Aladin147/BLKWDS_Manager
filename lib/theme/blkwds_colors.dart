import 'package:flutter/material.dart';
import 'dart:ui';

/// Extension to provide additional color utilities
extension ColorExtension on Color {
  /// Creates a new color with modified values
  Color withValues({int? red, int? green, int? blue, int? alpha, double? opacity}) {
    final alphaValue = opacity != null
        ? (opacity.clamp(0.0, 1.0) * 255).round()
        : alpha ?? a.round();

    return Color.fromARGB(
      alphaValue,
      red ?? r.round(),
      green ?? g.round(),
      blue ?? b.round(),
    );
  }

  /// Brightens the color by the given percentage (0-100)
  Color brighten(int percentage) {
    assert(percentage >= 0 && percentage <= 100);
    final factor = percentage / 100;
    return Color.fromARGB(
      a.round(),
      (r + ((255 - r) * factor)).round().clamp(0, 255),
      (g + ((255 - g) * factor)).round().clamp(0, 255),
      (b + ((255 - b) * factor)).round().clamp(0, 255),
    );
  }

  /// Darkens the color by the given percentage (0-100)
  Color darken(int percentage) {
    assert(percentage >= 0 && percentage <= 100);
    final factor = percentage / 100;
    return Color.fromARGB(
      a.round(),
      (r * (1 - factor)).round().clamp(0, 255),
      (g * (1 - factor)).round().clamp(0, 255),
      (b * (1 - factor)).round().clamp(0, 255),
    );
  }
}

/// BLKWDS Manager Color Palette
/// Modern, high-contrast color system with improved readability
class BLKWDSColors {
  // Primary Colors
  static const Color blkwdsGreen = Color(0xFF1DB954); // Brighter, more modern green
  static const Color white = Color(0xFFFFFFFF);
  static const Color deepBlack = Color(0xFF121212); // Rich black for backgrounds
  static const Color slateGrey = Color(0xFFADBBCC); // Softer, more modern grey
  static const Color transparent = Color(0x00000000); // Fully transparent color

  // Background Colors
  static const Color backgroundDark = Color(0xFF0F1210); // Desaturated charcoal green background
  static const Color backgroundMedium = Color(0xFF1D2A23); // Subtle desaturated green surfaces
  static const Color backgroundLight = Color(0xFF2A3932); // Elevated surfaces

  // Accent Colors
  static const Color mustardOrange = Color(0xFFFFCC66); // Soft, modern gold for actions
  static const Color electricMint = Color(0xFF4ECDC4); // Teal-mint that pops against dark bg
  static const Color alertCoral = Color(0xFFDA5E54); // Alert red, muted to stay readable
  static const Color accentTeal = Color(0xFF7AB4D3); // Faint cool blue for subtle structure
  static const Color accentPurple = Color(0xFF9F7AEA); // Bright, modern purple
  static const Color errorRed = Color(0xFFDA5E54); // Consistent error color

  // Additional Accent Colors
  static const Color successGreen = Color(0xFF6BD99F); // Positive state - clean & distinct
  static const Color warningAmber = Color(0xFFFFAA5E); // Orange-tinted OUT state
  static const Color infoBlue = Color(0xFF7AB4D3); // Faint cool blue for structure
  static const Color purpleAccent = Color(0xFF9F7AEA); // Additional accent color
  static const Color pinkAccent = Color(0xFFED64A6); // Additional accent color

  // Status Colors
  static const Color statusIn = successGreen;
  static const Color statusOut = warningAmber;
  static const Color statusMaintenance = errorRed;
  static const Color statusBooked = infoBlue;

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // Main UI text
  static const Color textSecondary = Color(0xFFCCCCCC); // Labels, notes, helper text
  static const Color textDisabled = Color(0xFF718096); // Disabled text with sufficient contrast
  static const Color textHint = Color(0xFF8A94A6); // Hint text with better visibility

  // UI Element Colors
  static const Color cardBackground = backgroundMedium;
  static const Color appBackground = backgroundDark;
  static const Color primaryButtonBackground = mustardOrange; // Soft gold for CTAs
  static const Color primaryButtonText = Color(0xFF1E1E1E); // Dark text for contrast on gold
  static const Color secondaryButtonBackground = backgroundLight;
  static const Color secondaryButtonText = white;
  static const Color secondaryButtonBorder = accentTeal;

  // Input Colors
  static const Color inputBackground = Color(0xFF2D3748); // Slightly lighter for better contrast
  static const Color inputBorder = Color(0xFF4A5568); // More visible border
  static const Color inputFocusBorder = accentTeal;
  static const Color inputErrorBorder = errorRed;
  static const Color inputSuccessBorder = successGreen;

  // Divider and Border Colors
  static const Color divider = Color(0xFF2A3932); // More subtle divider
  static const Color border = Color(0xFF2A3932); // Barely-visible separators

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // 50% black for overlays
  static const Color scrim = Color(0xCC000000); // 80% black for modal backgrounds

  // Alpha Values (0-255)
  static const int alphaFull = 255;      // 100% opacity
  static const int alphaHigh = 230;      // 90% opacity
  static const int alphaMediumHigh = 179; // 70% opacity
  static const int alphaMedium = 128;     // 50% opacity
  static const int alphaMediumLow = 102;  // 40% opacity
  static const int alphaLow = 77;        // 30% opacity
  static const int alphaVeryLow = 51;     // 20% opacity
  static const int alphaNone = 0;        // 0% opacity

  // Gradient Colors
  static const Color gradientStart = Color(0xFF1A202C);
  static const Color gradientEnd = Color(0xFF2D3748);

  // Focus and Selection Colors
  static const Color focusRing = accentTeal;
  static const Color selection = Color(0xFF2C5282);

  // Additional Colors for Backward Compatibility
  static const Color primary = mustardOrange;
  static const Color success = successGreen;
  static const Color textLight = textPrimary;
}
