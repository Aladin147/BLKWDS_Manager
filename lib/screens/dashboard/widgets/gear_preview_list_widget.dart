import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';

import '../../gear_management/widgets/gear_card_with_note.dart';
import '../dashboard_controller.dart';

/// GearPreviewListWidget
/// Displays a preview of recently used gear items
class GearPreviewListWidget extends StatelessWidget {
  final DashboardController controller;
  final Function(Gear, String?) onCheckout;
  final Function(Gear, String?) onReturn;
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
      child: Column(
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
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Filter tabs
          Row(
            children: [
              _buildFilterChip('All Gear', true),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              _buildFilterChip('Checked Out', false),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              _buildFilterChip('Available', false),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Warning banner for overdue gear
          if (_hasOverdueGear())
            Container(
              margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
              padding: const EdgeInsets.symmetric(
                horizontal: BLKWDSConstants.spacingMedium,
                vertical: BLKWDSConstants.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: BLKWDSColors.errorRed.withValues(alpha: 20),
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                border: Border.all(color: BLKWDSColors.errorRed.withValues(alpha: 50)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: BLKWDSColors.errorRed,
                    size: 20,
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  Expanded(
                    child: Text(
                      'OVERDUE: OVERDUE BY 24 HOURS',
                      style: BLKWDSTypography.labelMedium.copyWith(
                        color: BLKWDSColors.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Gear list
          Expanded(
            child: ValueListenableBuilder<List<Gear>>(
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

                return ListView.builder(
                  itemCount: recentGear.length,
                  itemBuilder: (context, index) {
                    return _buildGearItem(recentGear[index]);
                  },
                );
              },
            ),
          ),
        ],
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

  // Build a filter chip
  Widget _buildFilterChip(String label, bool isSelected) {
    return InkWell(
      onTap: () {
        // In a real app, this would filter the gear list
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? BLKWDSColors.accentTeal : BLKWDSColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: BLKWDSTypography.labelSmall.copyWith(
            color: isSelected ? Colors.white : BLKWDSColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // Build a gear item
  Widget _buildGearItem(Gear gear) {
    return GearCardWithNote(
      gear: gear,
      onCheckout: onCheckout,
      onCheckin: onReturn,
      isCompact: true,
    );
  }

  // Check if there is any overdue gear
  bool _hasOverdueGear() {
    // For demo purposes, always return true to show the banner
    // In a real app, this would check if any gear is overdue
    return true;
  }
}
