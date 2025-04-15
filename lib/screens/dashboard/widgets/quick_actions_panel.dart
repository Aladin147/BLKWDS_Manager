import 'package:flutter/material.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_button.dart';

/// QuickActionsPanel
/// Displays quick action buttons for common tasks
class QuickActionsPanel extends StatelessWidget {
  final VoidCallback onAddGear;
  final VoidCallback onOpenBookingPanel;
  final VoidCallback? onExportLogs;

  const QuickActionsPanel({
    super.key,
    required this.onAddGear,
    required this.onOpenBookingPanel,
    this.onExportLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: BLKWDSColors.backgroundMedium,
        borderRadius: BorderRadius.circular(BLKWDSConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: BLKWDSColors.deepBlack.withValues(alpha: 40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: BLKWDSTypography.titleMedium.copyWith(
              color: BLKWDSColors.textPrimary,
            ),
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Add Gear Button
          BLKWDSButton(
            onPressed: onAddGear,
            label: 'Add Gear',
            icon: Icons.add_circle_outline,
            type: BLKWDSButtonType.primary,
            isFullWidth: true,
          ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Open Booking Panel Button
          BLKWDSButton(
            onPressed: onOpenBookingPanel,
            label: 'Open Booking Panel',
            icon: Icons.calendar_today,
            type: BLKWDSButtonType.primary,
            isFullWidth: true,
          ),

          if (onExportLogs != null) ...[
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Export Logs Button
            BLKWDSButton(
              onPressed: onExportLogs!,
              label: 'Export Logs',
              icon: Icons.download,
              type: BLKWDSButtonType.secondary,
              isFullWidth: true,
            ),
          ],
        ],
      ),
      ),
    );
  }
}
