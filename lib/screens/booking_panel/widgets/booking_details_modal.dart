import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';

/// BookingDetailsModal
/// Widget for displaying booking details in a modal
class BookingDetailsModal extends StatelessWidget {
  final Booking booking;
  final Project? project;
  final List<Member> members;
  final List<Gear> gear;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookingDetailsModal({
    super.key,
    required this.booking,
    required this.project,
    required this.members,
    required this.gear,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Format dates and times
    final dateFormat = DateFormat.yMMMMd();
    final timeFormat = DateFormat.jm();

    final startDateStr = dateFormat.format(booking.startDate);
    final startTimeStr = timeFormat.format(booking.startDate);
    final endDateStr = dateFormat.format(booking.endDate);
    final endTimeStr = timeFormat.format(booking.endDate);

    // Check if booking is in the past, current, or future
    final now = DateTime.now();
    final isPast = booking.endDate.isBefore(now);
    final isCurrent = booking.startDate.isBefore(now) && booking.endDate.isAfter(now);

    // Determine status color and text
    Color statusColor;
    String statusText;

    if (isPast) {
      statusColor = BLKWDSColors.slateGrey;
      statusText = 'Past';
    } else if (isCurrent) {
      statusColor = BLKWDSColors.blkwdsGreen;
      statusText = 'Current';
    } else {
      statusColor = BLKWDSColors.electricMint;
      statusText = 'Upcoming';
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(BLKWDSConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with project name and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    project?.title ?? 'Unknown Project',
                    style: BLKWDSTypography.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: BLKWDSTypography.labelMedium.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Date and time
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: BLKWDSColors.slateGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  startDateStr == endDateStr
                      ? '$startDateStr, $startTimeStr - $endTimeStr'
                      : '$startDateStr $startTimeStr - $endDateStr $endTimeStr',
                  style: BLKWDSTypography.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Studio space
            if (booking.isRecordingStudio || booking.isProductionStudio) ...[
              Row(
                children: [
                  const Icon(
                    Icons.business,
                    size: 18,
                    color: BLKWDSColors.slateGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    [
                      if (booking.isRecordingStudio) 'Recording Studio',
                      if (booking.isProductionStudio) 'Production Studio',
                    ].join(', '),
                    style: BLKWDSTypography.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
            ],

            // Gear
            if (gear.isNotEmpty) ...[
              Text(
                'Gear',
                style: BLKWDSTypography.titleSmall,
              ),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: BLKWDSColors.slateGrey.withValues(alpha: 75)),
                  borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
                  itemCount: gear.length,
                  itemBuilder: (context, index) {
                    final gearItem = gear[index];
                    final assignedMemberId = booking.assignedGearToMember?[gearItem.id];
                    final assignedMember = assignedMemberId != null
                        ? members.firstWhere(
                            (m) => m.id == assignedMemberId,
                            orElse: () => Member(name: 'Unknown', role: 'Unknown'),
                          )
                        : null;

                    return ListTile(
                      title: Text(gearItem.name),
                      subtitle: Text(gearItem.category),
                      trailing: assignedMember != null
                          ? Chip(
                              label: Text(assignedMember.name),
                              backgroundColor: BLKWDSColors.electricMint.withValues(alpha: 50),
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
            ],

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BLKWDSButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                  type: BLKWDSButtonType.secondary,
                  isSmall: true,
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                BLKWDSButton(
                  label: 'Edit',
                  icon: Icons.edit,
                  type: BLKWDSButtonType.secondary,
                  isSmall: true,
                  onPressed: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                BLKWDSButton(
                  label: 'Delete',
                  icon: Icons.delete,
                  type: BLKWDSButtonType.danger,
                  isSmall: true,
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
