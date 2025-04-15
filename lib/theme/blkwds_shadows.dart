import 'package:flutter/material.dart';
import 'blkwds_colors.dart';

/// BLKWDS Manager Shadow System
///
/// Provides standardized shadows for consistent depth throughout the app
/// Enhanced for better visual hierarchy and dark mode compatibility
class BLKWDSShadows {
  // Shadow Levels
  static const int level0 = 0; // No shadow
  static const int level1 = 1; // Subtle shadow
  static const int level2 = 2; // Card shadow
  static const int level3 = 3; // Elevated card shadow
  static const int level4 = 4; // Dialog shadow
  static const int level5 = 5; // Modal shadow

  // Shadow Colors
  static final Color _shadowColor = BLKWDSColors.deepBlack.withValues(alpha: 100);
  static final Color _accentShadowColor = BLKWDSColors.accentTeal.withValues(alpha: 40);
  static final Color _errorShadowColor = BLKWDSColors.errorRed.withValues(alpha: 40);
  static final Color _successShadowColor = BLKWDSColors.successGreen.withValues(alpha: 40);
  static final Color _warningShadowColor = BLKWDSColors.warningAmber.withValues(alpha: 40);
  static final Color _infoShadowColor = BLKWDSColors.infoBlue.withValues(alpha: 40);

  /// Get a standard shadow with the specified elevation level
  static List<BoxShadow> getShadow(int level) {
    switch (level) {
      case level0:
        return [];
      case level1:
        return [
          BoxShadow(
            color: _shadowColor.withValues(alpha: 40),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ];
      case level2:
        return [
          BoxShadow(
            color: _shadowColor.withValues(alpha: 60),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ];
      case level3:
        return [
          BoxShadow(
            color: _shadowColor.withValues(alpha: 70),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ];
      case level4:
        return [
          BoxShadow(
            color: _shadowColor.withValues(alpha: 80),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ];
      case level5:
        return [
          BoxShadow(
            color: _shadowColor.withValues(alpha: 90),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ];
      default:
        return getShadow(level2); // Default to level 2
    }
  }

  /// Get a shadow with accent color glow
  static List<BoxShadow> getAccentShadow(int level) {
    final standardShadows = getShadow(level);

    if (level == level0) {
      return [];
    }

    return [
      ...standardShadows,
      BoxShadow(
        color: _accentShadowColor,
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
    ];
  }

  /// Get a shadow with custom color
  static List<BoxShadow> getColoredShadow(int level, Color color) {
    if (level == level0) {
      return [];
    }

    final standardShadows = getShadow(level);
    final coloredShadow = BoxShadow(
      color: color.withValues(alpha: 50),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 0),
    );

    return [
      ...standardShadows,
      coloredShadow,
    ];
  }

  /// Get a shadow for a focused element
  static List<BoxShadow> getFocusShadow() {
    return [
      BoxShadow(
        color: _shadowColor.withValues(alpha: 70),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: BLKWDSColors.accentTeal.withValues(alpha: 50),
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
    ];
  }

  /// Get a shadow for an error state
  static List<BoxShadow> getErrorShadow() {
    return [
      BoxShadow(
        color: _shadowColor.withValues(alpha: 70),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: _errorShadowColor,
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
    ];
  }

  /// Get a shadow for a success state
  static List<BoxShadow> getSuccessShadow() {
    return [
      BoxShadow(
        color: _shadowColor.withValues(alpha: 70),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: _successShadowColor,
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
    ];
  }

  /// Get a shadow for a warning state
  static List<BoxShadow> getWarningShadow() {
    return [
      BoxShadow(
        color: _shadowColor.withValues(alpha: 70),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: _warningShadowColor,
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
    ];
  }

  /// Get a shadow for a hover state
  static List<BoxShadow> getHoverShadow() {
    return [
      BoxShadow(
        color: _shadowColor.withValues(alpha: 80),
        blurRadius: 12,
        spreadRadius: 2,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: _accentShadowColor.withValues(alpha: 30),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 0),
      ),
    ];
  }

  /// Get a shadow for an active/pressed state
  static List<BoxShadow> getActiveShadow() {
    return [
      BoxShadow(
        color: _shadowColor.withValues(alpha: 90),
        blurRadius: 6,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: _accentShadowColor.withValues(alpha: 40),
        blurRadius: 6,
        spreadRadius: 0,
        offset: const Offset(0, 0),
      ),
    ];
  }

  /// Get a shadow for a disabled state
  static List<BoxShadow> getDisabledShadow() {
    return [
      BoxShadow(
        color: _shadowColor.withValues(alpha: 40),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Get a shadow for an info state
  static List<BoxShadow> getInfoShadow() {
    return [
      BoxShadow(
        color: _shadowColor.withValues(alpha: 70),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: _infoShadowColor,
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
    ];
  }

  /// Get a shadow for a card with hover effect
  static List<BoxShadow> getCardHoverShadow() {
    return [
      BoxShadow(
        color: _shadowColor.withValues(alpha: 80),
        blurRadius: 15,
        spreadRadius: 1,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: _accentShadowColor.withValues(alpha: 20),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 0),
      ),
    ];
  }
}
