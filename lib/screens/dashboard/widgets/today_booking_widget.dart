import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';

import '../dashboard_controller.dart';

/// TodayBookingWidget
/// Displays bookings scheduled for today
class TodayBookingWidget extends StatelessWidget {
  final DashboardController controller;

  const TodayBookingWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: BLKWDSColors.white,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: BLKWDSColors.deepBlack.withValues(alpha: 25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Bookings',
            style: BLKWDSTypography.titleMedium.copyWith(
              color: BLKWDSColors.blkwdsGreen,
            ),
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          ValueListenableBuilder<List<Booking>>(
            valueListenable: controller.bookingList,
            builder: (context, bookings, _) {
              final todayBookings = _getTodayBookings(bookings);

              if (todayBookings.isEmpty) {
                return Center(
                  child: Text(
                    'No bookings for today',
                    style: BLKWDSTypography.bodyMedium,
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: todayBookings.take(3).map((booking) => _buildBookingItem(context, booking)).toList(),
              );
            },
          ),
        ],
      ),
      ),
    );
  }

  // Get bookings for today
  List<Booking> _getTodayBookings(List<Booking> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return bookings.where((booking) {
      final bookingDate = DateTime(
        booking.startDate.year,
        booking.startDate.month,
        booking.startDate.day,
      );
      return bookingDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Build a booking item
  Widget _buildBookingItem(BuildContext context, Booking booking) {
    // Get project name
    final project = controller.projectList.value.firstWhere(
      (p) => p.id == booking.projectId,
      orElse: () => Project(id: 0, title: 'Unknown Project', description: ''),
    );

    // Get assigned members
    final assignedMembers = <Member>[];
    if (booking.assignedGearToMember != null) {
      final memberIds = booking.assignedGearToMember!.values.toSet();
      for (final memberId in memberIds) {
        final member = controller.memberList.value.firstWhere(
          (m) => m.id == memberId,
          orElse: () => Member(id: 0, name: 'Unknown'),
        );
        assignedMembers.add(member);
      }
    }

    // Get primary member (first assigned member or null)
    final primaryMember = assignedMembers.isNotEmpty ? assignedMembers.first : null;

    // Get first gear item for icon
    final firstGearId = booking.gearIds.isNotEmpty ? booking.gearIds.first : null;
    final firstGear = firstGearId != null
        ? controller.gearList.value.firstWhere(
            (g) => g.id == firstGearId,
            orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
          )
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
        child: Row(
          children: [
            // Gear or booking type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: BLKWDSColors.slateGrey.withValues(alpha: 25),
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius / 2),
              ),
              child: Icon(
                _getBookingIcon(booking, firstGear),
                color: BLKWDSColors.blkwdsGreen,
              ),
            ),
            const SizedBox(width: BLKWDSConstants.spacingSmall),

            // Booking details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project name
                  Text(
                    project.title,
                    style: BLKWDSTypography.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Member name
                  if (primaryMember != null)
                    Text(
                      primaryMember.name,
                      style: BLKWDSTypography.bodyMedium,
                    ),

                  // Time
                  Text(
                    _formatBookingTime(booking),
                    style: BLKWDSTypography.bodySmall.copyWith(
                      color: BLKWDSColors.slateGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Gear count badge
            if (booking.gearIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: BLKWDSColors.slateGrey.withValues(alpha: 25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${booking.gearIds.length} items',
                  style: BLKWDSTypography.labelSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Get icon for booking based on type
  IconData _getBookingIcon(Booking booking, Gear? firstGear) {
    if (booking.isRecordingStudio) {
      return Icons.mic;
    } else if (booking.isProductionStudio) {
      return Icons.videocam;
    } else if (firstGear != null) {
      // Use category-specific icon if available
      switch (firstGear.category.toLowerCase()) {
        case 'camera':
          return Icons.camera_alt;
        case 'audio':
          return Icons.mic;
        case 'lighting':
          return Icons.lightbulb;
        default:
          return Icons.camera_alt;
      }
    } else {
      return Icons.event;
    }
  }

  // Format booking time
  String _formatBookingTime(Booking booking) {
    final startTime = TimeOfDay.fromDateTime(booking.startDate);
    final endTime = TimeOfDay.fromDateTime(booking.endDate);

    return '${_formatTimeOfDay(startTime)} – ${_formatTimeOfDay(endTime)}';
  }

  // Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
