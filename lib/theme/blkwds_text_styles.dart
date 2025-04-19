import 'package:flutter/material.dart';
import 'blkwds_colors.dart';

/// BLKWDS Manager Text Styles
/// Provides consistent text styling for the app
class BLKWDSTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.white,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.white,
    height: 1.2,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: BLKWDSColors.white,
    height: 1.2,
  );

  // Body text
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: BLKWDSColors.white,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.white,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: BLKWDSColors.white,
    height: 1.5,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: BLKWDSColors.slateGrey,
    height: 1.4,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.medium,
    color: BLKWDSColors.white,
    height: 1.0,
  );

  // Label
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.medium,
    color: BLKWDSColors.white,
    height: 1.2,
  );
}
