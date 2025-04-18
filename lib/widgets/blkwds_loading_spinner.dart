import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';

/// BLKWDSEnhancedLoadingIndicator
/// A custom loading spinner with BLKWDS styling
class BLKWDSEnhancedLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const BLKWDSEnhancedLoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? BLKWDSColors.blkwdsGreen,
        ),
      ),
    );
  }
}
