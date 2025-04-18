import 'package:flutter/material.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../widgets/blkwds_widgets.dart';

/// SettingsSection
/// Widget for displaying a section in the settings screen
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          BLKWDSEnhancedText.titleLarge(
            title,
            color: BLKWDSColors.blkwdsGreen,
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Section content
          BLKWDSEnhancedCard(
            width: double.infinity,
            padding: padding ?? const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            animateOnHover: true,
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
