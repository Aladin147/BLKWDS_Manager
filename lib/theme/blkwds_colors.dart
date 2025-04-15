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
/// Based on the visual guidelines document with enhanced contrast and readability
class BLKWDSColors {
  // Primary Colors
  static const Color blkwdsGreen = Color(0xFF2F6846);
  static const Color white = Color(0xFFFFFFFF);
  static const Color deepBlack = Color(0xFF121212); // Darker for better contrast
  static const Color slateGrey = Color(0xFF9E9E9E); // Lighter for better readability

  // Background Colors
  static const Color backgroundDark = Color(0xFF121212); // Main background
  static const Color backgroundMedium = Color(0xFF1E1E1E); // Card backgrounds
  static const Color backgroundLight = Color(0xFF2C2C2C); // Elevated surfaces

  // Accent Colors
  static const Color mustardOrange = Color(0xFFFFB74D); // Brighter for better visibility
  static const Color electricMint = Color(0xFF69F0AE); // Adjusted for better contrast
  static const Color alertCoral = Color(0xFFFF5252); // Brighter for better visibility
  static const Color accentTeal = Color(0xFF64FFDA); // Adjusted for better contrast
  static const Color errorRed = Color(0xFFFF5252); // Consistent with alertCoral

  // Additional Accent Colors
  static const Color successGreen = Color(0xFF4CAF50); // For success states
  static const Color warningAmber = Color(0xFFFFD740); // For warning states
  static const Color infoBlue = Color(0xFF448AFF); // For information states

  // Status Colors
  static const Color statusIn = successGreen;
  static const Color statusOut = warningAmber;
  static const Color statusMaintenance = errorRed;
  static const Color statusBooked = infoBlue;

  // Text Colors
  static const Color textPrimary = white; // Primary text color
  static const Color textSecondary = Color(0xFFBDBDBD); // Secondary text color
  static const Color textDisabled = Color(0xFF757575); // Disabled text color
  static const Color textHint = Color(0xFF9E9E9E); // Hint text color

  // UI Element Colors
  static const Color cardBackground = backgroundMedium;
  static const Color appBackground = backgroundDark;
  static const Color primaryButtonBackground = mustardOrange;
  static const Color primaryButtonText = deepBlack;
  static const Color secondaryButtonBackground = backgroundLight;
  static const Color secondaryButtonText = white;
  static const Color secondaryButtonBorder = slateGrey;

  // Input Colors
  static const Color inputBackground = backgroundLight;
  static const Color inputBorder = slateGrey;
  static const Color inputFocusBorder = accentTeal;
  static const Color inputErrorBorder = errorRed;
  static const Color inputSuccessBorder = successGreen;

  // Divider and Border Colors
  static const Color divider = Color(0xFF424242); // Subtle divider color
  static const Color border = Color(0xFF616161); // Standard border color

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // 50% black for overlays
  static const Color scrim = Color(0xCC000000); // 80% black for modal backgrounds
}
