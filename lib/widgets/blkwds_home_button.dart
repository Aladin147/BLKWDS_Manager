import 'package:flutter/material.dart';
import '../services/navigation_helper.dart';
import '../theme/blkwds_colors.dart';

/// A reusable home button widget that navigates to the dashboard
class BLKWDSHomeButton extends StatelessWidget {
  /// Creates a home button widget
  const BLKWDSHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home, size: 24),
      color: BLKWDSColors.accentTeal,
      tooltip: 'Home',
      onPressed: () {
        NavigationHelper.navigateToDashboard(clearStack: true);
      },
    );
  }
}
