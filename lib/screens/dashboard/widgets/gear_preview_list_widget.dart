import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';

import '../../../widgets/blkwds_widgets.dart';

import '../../gear_management/widgets/gear_card_with_note.dart';
import '../dashboard_controller.dart';

/// GearPreviewListWidget
/// Displays a preview of recently used gear items
class GearPreviewListWidget extends StatefulWidget {
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
  State<GearPreviewListWidget> createState() => _GearPreviewListWidgetState();
}

/// Filter options for the gear list
enum GearFilter {
  all,
  checkedOut,
  available
}

class _GearPreviewListWidgetState extends State<GearPreviewListWidget> {
  // Currently selected filter
  GearFilter _selectedFilter = GearFilter.all;

  @override
  Widget build(BuildContext context) {
    return BLKWDSEnhancedCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      animateOnHover: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and view all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CategoryIconWidget(
                    category: 'Camera',
                    size: 32,
                    iconSize: 20,
                    iconColor: BLKWDSColors.accentTeal,
                    backgroundColor: BLKWDSColors.accentTeal.withAlpha(50),
                    borderRadius: 8,
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  BLKWDSEnhancedText.titleLarge(
                    'Recent Gear Activity',
                    color: BLKWDSColors.textPrimary,
                  ),
                ],
              ),
              BLKWDSEnhancedButton(
                onPressed: widget.onViewAllGear,
                label: 'View All',
                icon: Icons.visibility,
                type: BLKWDSEnhancedButtonType.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                  vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Filter tabs
          Row(
            children: [
              _buildFilterChip('All Gear', _selectedFilter == GearFilter.all, GearFilter.all),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              _buildFilterChip('Checked Out', _selectedFilter == GearFilter.checkedOut, GearFilter.checkedOut),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              _buildFilterChip('Available', _selectedFilter == GearFilter.available, GearFilter.available),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Warning banner for overdue gear
          if (_hasOverdueGear())
            Column(
              children: [
                BLKWDSEnhancedCard(
                  type: BLKWDSEnhancedCardType.warning,
                  padding: const EdgeInsets.symmetric(
                    horizontal: BLKWDSConstants.spacingMedium,
                    vertical: BLKWDSConstants.spacingSmall,
                  ),
                  borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                  borderColor: BLKWDSColors.warningAmber,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: BLKWDSColors.warningAmber,
                        size: 20,
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingSmall),
                      BLKWDSEnhancedText.labelLarge(
                        'OVERDUE GEAR: CHECKED OUT FOR 24+ HOURS',
                        color: BLKWDSColors.warningAmber,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: BLKWDSConstants.spacingSmall),
              ],
            ),

          // Gear list
          SizedBox(
            height: 300,
            child: ValueListenableBuilder<List<Gear>>(
              valueListenable: widget.controller.gearList,
              builder: (context, gearList, _) {
                final recentGear = _getFilteredGear(gearList);

                if (recentGear.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                      child: BLKWDSEnhancedText.bodyMedium(
                        'No recent gear activity',
                        color: BLKWDSColors.textSecondary,
                      ),
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

  // Get filtered gear based on the selected filter
  List<Gear> _getFilteredGear(List<Gear> allGear) {
    // Apply filter
    List<Gear> filteredGear;
    switch (_selectedFilter) {
      case GearFilter.all:
        filteredGear = allGear;
        break;
      case GearFilter.checkedOut:
        filteredGear = allGear.where((gear) => gear.isOut).toList();
        break;
      case GearFilter.available:
        filteredGear = allGear.where((gear) => !gear.isOut).toList();
        break;
    }

    // Limit to 5 items for the preview
    return filteredGear.take(5).toList();
  }

  // Build a filter chip
  Widget _buildFilterChip(String label, bool isSelected, GearFilter filter) {
    return BLKWDSEnhancedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      label: label,
      type: isSelected ? BLKWDSEnhancedButtonType.primary : BLKWDSEnhancedButtonType.tertiary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderRadius: BorderRadius.circular(16),
    );
  }

  // Build a gear item
  Widget _buildGearItem(Gear gear) {
    return GearCardWithNote(
      gear: gear,
      onCheckout: widget.onCheckout,
      onCheckin: widget.onReturn,
      isCompact: true,
    );
  }

  // Check if there is any overdue gear
  bool _hasOverdueGear() {
    final now = DateTime.now();
    final overdueThreshold = now.subtract(const Duration(hours: 24));

    // Get all checked out gear
    final checkedOutGear = widget.controller.gearList.value.where((gear) => gear.isOut).toList();

    // Check if any gear has been checked out for more than 24 hours
    for (final gear in checkedOutGear) {
      // Get the most recent activity log for this gear
      final activityLogs = widget.controller.recentActivity.value
          .where((log) => log.gearId == gear.id && log.checkedOut)
          .toList();

      // Sort by timestamp (most recent first)
      activityLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Get the most recent activity log
      final activityLog = activityLogs.isNotEmpty ? activityLogs.first : null;

      // If we found an activity log and it's older than 24 hours, we have overdue gear
      if (activityLog != null && activityLog.timestamp.isBefore(overdueThreshold)) {
        return true;
      }
    }

    return false;
  }
}
