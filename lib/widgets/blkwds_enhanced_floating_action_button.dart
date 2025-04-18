import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';


/// BLKWDSEnhancedFloatingActionButton
/// A custom floating action button with BLKWDS styling
class BLKWDSEnhancedFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final double? elevation;

  const BLKWDSEnhancedFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? BLKWDSColors.primaryButtonBackground,
      foregroundColor: foregroundColor ?? BLKWDSColors.primaryButtonText,
      elevation: elevation ?? 4.0,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
