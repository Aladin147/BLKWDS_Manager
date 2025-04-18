import 'package:flutter/material.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../widgets/blkwds_enhanced_widgets.dart';

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
    return BLKWDSEnhancedCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      animateOnHover: true,
      useGradient: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: BLKWDSColors.accentTeal.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flash_on,
                    color: BLKWDSColors.accentTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                BLKWDSEnhancedText.titleLarge(
                  'Quick Actions',
                  color: BLKWDSColors.textPrimary,
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Add Gear Button
            BLKWDSEnhancedButton(
              onPressed: onAddGear,
              label: 'Add Gear',
              icon: Icons.add_circle_outline,
              type: BLKWDSEnhancedButtonType.primary,
              width: double.infinity,
            ),

            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Open Booking Panel Button
            BLKWDSEnhancedButton(
              onPressed: onOpenBookingPanel,
              label: 'Open Booking Panel',
              icon: Icons.calendar_today,
              type: BLKWDSEnhancedButtonType.primary,
              width: double.infinity,
            ),

            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Manage Members Button
            BLKWDSEnhancedButton(
              onPressed: onManageMembers,
              label: 'Manage Members',
              icon: Icons.people,
              type: BLKWDSEnhancedButtonType.primary,
              width: double.infinity,
            ),

            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Manage Projects Button
            BLKWDSEnhancedButton(
              onPressed: onManageProjects,
              label: 'Manage Projects',
              icon: Icons.folder,
              type: BLKWDSEnhancedButtonType.primary,
              width: double.infinity,
            ),

            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Manage Gear Button
            BLKWDSEnhancedButton(
              onPressed: onManageGear,
              label: 'Manage Gear',
              icon: Icons.videocam,
              type: BLKWDSEnhancedButtonType.primary,
              width: double.infinity,
            ),

            if (onManageStudios != null) ...[
              const SizedBox(height: BLKWDSConstants.spacingMedium),

              // Manage Studios Button
              BLKWDSEnhancedButton(
                onPressed: onManageStudios!,
                label: 'Manage Studios',
                icon: Icons.business,
                type: BLKWDSEnhancedButtonType.primary,
                width: double.infinity,
              ),
            ],

            if (onExportLogs != null) ...[
              const SizedBox(height: BLKWDSConstants.spacingMedium),

              // Export Logs Button
              BLKWDSEnhancedButton(
                onPressed: onExportLogs!,
                label: 'Export Logs',
                icon: Icons.download,
                type: BLKWDSEnhancedButtonType.secondary,
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
