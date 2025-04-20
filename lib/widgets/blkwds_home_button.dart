import 'package:flutter/material.dart';
import '../services/navigation_helper.dart';
import '../theme/blkwds_colors.dart';
import '../widgets/blkwds_enhanced_widgets.dart';

/// A reusable home button widget that navigates to the dashboard
class BLKWDSHomeButton extends StatelessWidget {
  /// Creates a home button widget
  const BLKWDSHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BLKWDSEnhancedButton.icon(
      icon: Icons.home,
      onPressed: () {
        NavigationHelper.navigateToDashboard(clearStack: true);
      },
      type: BLKWDSEnhancedButtonType.tertiary,
      backgroundColor: Colors.transparent,
      foregroundColor: BLKWDSColors.accentTeal,
      // No tooltip parameter in BLKWDSEnhancedButton
    );
  }
}
