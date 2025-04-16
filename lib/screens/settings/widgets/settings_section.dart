import 'package:flutter/material.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';

/// SettingsSection
/// Widget for displaying a section in the settings screen
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SettingsSection({
    Key? key,
    required this.title,
    required this.children,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            title,
            style: BLKWDSTypography.titleMedium.copyWith(
              color: BLKWDSColors.blkwdsGreen,
            ),
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Section content
          Container(
            width: double.infinity,
            padding: padding ?? const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            decoration: BoxDecoration(
              color: BLKWDSColors.backgroundMedium,
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: BLKWDSColors.deepBlack.withValues(alpha: 40),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
