import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_button.dart';
import '../dashboard_controller.dart';

/// GearPreviewListWidget
/// Displays a preview of recently used gear items
class GearPreviewListWidget extends StatelessWidget {
  final DashboardController controller;
  final Function(Gear) onCheckout;
  final Function(Gear) onReturn;
  final VoidCallback onViewAllGear;

  const GearPreviewListWidget({
    super.key,
    required this.controller,
    required this.onCheckout,
    required this.onReturn,
    required this.onViewAllGear,
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and view all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Gear Activity',
                style: BLKWDSTypography.titleMedium.copyWith(
                  color: BLKWDSColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: onViewAllGear,
                icon: const Icon(Icons.visibility),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: BLKWDSColors.accentTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Gear list
          ValueListenableBuilder<List<Gear>>(
            valueListenable: controller.gearList,
            builder: (context, gearList, _) {
              final recentGear = _getRecentGear(gearList);

              if (recentGear.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(BLKWDSConstants.spacingMedium),
                    child: Text('No recent gear activity'),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: recentGear.take(3).map((gear) => _buildGearItem(gear)).toList(),
              );
            },
          ),
        ],
      ),
      ),
    );
  }

  // Get recent gear (prioritize checked out gear, then recently used)
  List<Gear> _getRecentGear(List<Gear> allGear) {
    // First, get all checked out gear
    final checkedOutGear = allGear.where((gear) => gear.isOut).toList();

    // If we have 5 or more checked out gear, return the first 5
    if (checkedOutGear.length >= 5) {
      return checkedOutGear.take(5).toList();
    }

    // Otherwise, add some gear that's currently checked in
    final checkedInGear = allGear
        .where((gear) => !gear.isOut)
        .toList();

    // Add checked in gear until we have 5 items or run out of gear
    final result = [...checkedOutGear];
    final remainingSlots = 5 - result.length;

    if (remainingSlots > 0 && checkedInGear.isNotEmpty) {
      result.addAll(checkedInGear.take(remainingSlots));
    }

    return result;
  }

  // Build a gear item
  Widget _buildGearItem(Gear gear) {
    // For a real app, we would find the member who has the gear checked out
    // This would require additional data in the Gear model or a lookup table
    Member? assignedMember;
    // For demo purposes, just use the first member if gear is checked out
    if (gear.isOut && controller.memberList.value.isNotEmpty) {
      assignedMember = controller.memberList.value.first;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
        child: Row(
          children: [
            // Gear thumbnail
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: BLKWDSColors.backgroundLight,
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius / 2),
              ),
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),

            // Gear info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gear.name,
                    style: BLKWDSTypography.titleSmall,
                  ),
                  Text(
                    gear.category,
                    style: BLKWDSTypography.bodySmall,
                  ),
                  if (assignedMember != null)
                    Text(
                      'Checked out to: ${assignedMember.name}',
                      style: BLKWDSTypography.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: gear.isOut
                    ? BLKWDSColors.warningAmber.withValues(alpha: 25)
                    : BLKWDSColors.successGreen.withValues(alpha: 25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                gear.isOut ? 'OUT' : 'IN',
                style: BLKWDSTypography.labelMedium.copyWith(
                  color: gear.isOut
                      ? BLKWDSColors.warningAmber
                      : BLKWDSColors.successGreen,
                ),
              ),
            ),

            const SizedBox(width: BLKWDSConstants.spacingSmall),

            // Action button
            gear.isOut
                ? BLKWDSButton(
                    label: 'Return',
                    onPressed: () => onReturn(gear),
                    type: BLKWDSButtonType.secondary,
                    isSmall: true,
                  )
                : BLKWDSButton(
                    label: 'Check Out',
                    onPressed: () => onCheckout(gear),
                    type: BLKWDSButtonType.primary,
                    isSmall: true,
                  ),
          ],
        ),
      ),
    );
  }
}
