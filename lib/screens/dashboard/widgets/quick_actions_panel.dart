import 'package:flutter/material.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_button.dart';
import '../../../widgets/blkwds_card.dart';

/// QuickActionsPanel
/// Displays quick action buttons for common tasks
class QuickActionsPanel extends StatelessWidget {
  final VoidCallback onAddGear;
  final VoidCallback onOpenBookingPanel;
  final VoidCallback onManageMembers;
  final VoidCallback onManageProjects;
  final VoidCallback onManageGear;
  final VoidCallback? onManageStudios;
  final VoidCallback? onExportLogs;

  const QuickActionsPanel({
    super.key,
    required this.onAddGear,
    required this.onOpenBookingPanel,
    required this.onManageMembers,
    required this.onManageProjects,
    required this.onManageGear,
    this.onManageStudios,
    this.onExportLogs,
  });

  @override
  Widget build(BuildContext context) {
    return BLKWDSCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: BLKWDSColors.accentTeal.withValues(alpha: 50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: BLKWDSColors.accentTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              Text(
                'Quick Actions',
                style: BLKWDSTypography.titleMedium.copyWith(
                  color: BLKWDSColors.textPrimary,
                ),
              ),
            ],
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

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Manage Members Button
          BLKWDSButton(
            onPressed: onManageMembers,
            label: 'Manage Members',
            icon: Icons.people,
            type: BLKWDSButtonType.primary,
            isFullWidth: true,
          ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Manage Projects Button
          BLKWDSButton(
            onPressed: onManageProjects,
            label: 'Manage Projects',
            icon: Icons.folder,
            type: BLKWDSButtonType.primary,
            isFullWidth: true,
          ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Manage Gear Button
          BLKWDSButton(
            onPressed: onManageGear,
            label: 'Manage Gear',
            icon: Icons.videocam,
            type: BLKWDSButtonType.primary,
            isFullWidth: true,
          ),

          if (onManageStudios != null) ...[
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Manage Studios Button
            BLKWDSButton(
              onPressed: onManageStudios!,
              label: 'Manage Studios',
              icon: Icons.business,
              type: BLKWDSButtonType.primary,
              isFullWidth: true,
            ),
          ],

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
