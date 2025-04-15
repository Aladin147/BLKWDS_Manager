import 'package:flutter/material.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../booking_list_controller.dart';

/// BookingListHeader
/// Widget for displaying a header for a group of bookings
class BookingListHeader extends StatelessWidget {
  final BookingGroup group;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback? onFilterByGroup;
  
  const BookingListHeader({
    super.key,
    required this.group,
    required this.isExpanded,
    required this.onToggleExpanded,
    this.onFilterByGroup,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: BLKWDSConstants.spacingSmall,
      ),
      color: BLKWDSColors.backgroundLight,
      child: InkWell(
        onTap: onToggleExpanded,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BLKWDSConstants.spacingMedium,
            vertical: BLKWDSConstants.spacingSmall,
          ),
          child: Row(
            children: [
              // Expand/collapse icon
              Icon(
                isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                color: BLKWDSColors.textSecondary,
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              
              // Group title
              Expanded(
                child: Text(
                  group.title,
                  style: BLKWDSTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Booking count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: BLKWDSColors.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${group.bookings.length}',
                  style: BLKWDSTypography.labelSmall.copyWith(
                    color: BLKWDSColors.textSecondary,
                  ),
                ),
              ),
              
              // Filter button
              if (onFilterByGroup != null) ...[
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                IconButton(
                  icon: const Icon(Icons.filter_list, size: 18),
                  tooltip: 'Filter by this group',
                  onPressed: onFilterByGroup,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
