import 'package:flutter/material.dart';

/// BLKWDS Manager Color Palette
/// Based on the visual guidelines document
class BLKWDSColors {
  // Primary Colors
  static const Color blkwdsGreen = Color(0xFF2F6846);
  static const Color white = Color(0xFFFFFFFF);
  static const Color deepBlack = Color(0xFF1A1A1A);
  static const Color slateGrey = Color(0xFF4D4D4D);
  
  // Accent Colors
  static const Color mustardOrange = Color(0xFFEBA937);
  static const Color electricMint = Color(0xFF60F9A6);
  static const Color alertCoral = Color(0xFFF35D5D);
  static const Color accentTeal = Color(0xFF00F0B5);
  
  // Status Colors
  static const Color statusIn = electricMint;
  static const Color statusOut = mustardOrange;
  static const Color statusMaintenance = alertCoral;
  static const Color statusBooked = slateGrey;
  
  // UI Element Colors
  static const Color cardBackground = white;
  static const Color appBackground = blkwdsGreen;
  static const Color primaryButtonBackground = mustardOrange;
  static const Color primaryButtonText = deepBlack;
  static const Color secondaryButtonBorder = slateGrey;
  static const Color inputBackground = white;
  static const Color inputBorder = slateGrey;
  static const Color headingText = deepBlack;
  static const Color bodyText = slateGrey;
}
