import 'package:flutter/material.dart';
import 'blkwds_colors.dart';

/// BLKWDS Manager Gradient System
///
/// Provides standardized gradients for consistent styling throughout the app
class BLKWDSGradients {
  // Primary Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      BLKWDSColors.mustardOrange,
      Color(0xFFF5B951), // Lighter mustard
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [
      BLKWDSColors.electricMint,
      Color(0xFF8FFFC1), // Lighter mint
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      BLKWDSColors.accentTeal,
      Color(0xFF4FF7C9), // Lighter teal
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  // Background Gradients
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [
      BLKWDSColors.deepBlack,
      Color(0xFF252525), // Slightly lighter black
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient appBackgroundGradient = LinearGradient(
    colors: [
      BLKWDSColors.backgroundDark,
      BLKWDSColors.backgroundMedium, // Slightly lighter desaturated green
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  // Status Gradients
  static const LinearGradient successGradient = LinearGradient(
    colors: [
      BLKWDSColors.electricMint,
      Color(0xFF8FFFC1), // Lighter mint
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [
      BLKWDSColors.alertCoral,
      Color(0xFFF57F7F), // Lighter coral
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [
      BLKWDSColors.mustardOrange,
      Color(0xFFF5B951), // Lighter mustard
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  // Card Gradients
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF1F2220), // Slightly lighter desaturated green
      Color(0xFF171A18), // Darker desaturated green
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryCardGradient = LinearGradient(
    colors: [
      Color(0xFF1F2220), // Slightly lighter desaturated green
      Color(0xFF171A18), // Darker desaturated green
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.85],
  );

  // Button Gradients
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [
      BLKWDSColors.mustardOrange,
      Color(0xFFD99A32), // Darker mustard
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient secondaryButtonGradient = LinearGradient(
    colors: [
      Color(0xFF2A2A2A), // Slightly lighter than deep black
      Color(0xFF222222), // Slightly darker
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient dangerButtonGradient = LinearGradient(
    colors: [
      BLKWDSColors.alertCoral,
      Color(0xFFD35353), // Darker coral
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Overlay Gradients
  static const LinearGradient overlayGradient = LinearGradient(
    colors: [
      Colors.black54,
      Colors.black87,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Helper method to create a custom gradient
  static LinearGradient createGradient({
    required Color startColor,
    required Color endColor,
    AlignmentGeometry begin = Alignment.bottomLeft,
    AlignmentGeometry end = Alignment.topRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      colors: [startColor, endColor],
      begin: begin,
      end: end,
      stops: stops,
    );
  }

  // Helper method to create a custom radial gradient
  static RadialGradient createRadialGradient({
    required Color centerColor,
    required Color edgeColor,
    double radius = 0.5,
    AlignmentGeometry center = Alignment.center,
    List<double>? stops,
  }) {
    return RadialGradient(
      colors: [centerColor, edgeColor],
      radius: radius,
      center: center,
      stops: stops,
    );
  }

  // Helper method to create a custom sweep gradient
  static SweepGradient createSweepGradient({
    required List<Color> colors,
    AlignmentGeometry center = Alignment.center,
    double startAngle = 0.0,
    double endAngle = 6.28319, // 2*pi
    List<double>? stops,
  }) {
    return SweepGradient(
      colors: colors,
      center: center,
      startAngle: startAngle,
      endAngle: endAngle,
      stops: stops,
    );
  }
}
