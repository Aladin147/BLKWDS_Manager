import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_card.dart';
import '../../../widgets/blkwds_icon_container.dart';
import '../../../widgets/blkwds_status_badge.dart';
import '../dashboard_controller.dart';

/// TopBarSummaryWidget
/// Displays summary information at the top of the dashboard
class TopBarSummaryWidget extends StatelessWidget {
  final DashboardController controller;

  const TopBarSummaryWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: BLKWDSConstants.spacingMedium,
        horizontal: BLKWDSConstants.spacingMedium,
      ),
      decoration: const BoxDecoration(
        color: BLKWDSColors.backgroundDark,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: BLKWDSConstants.spacingMedium,
        runSpacing: BLKWDSConstants.spacingMedium,
        children: [
          // Gear Out Count
          ValueListenableBuilder<int>(
            valueListenable: controller.gearOutCount,
            builder: (context, count, _) {
              return _buildSummaryCard(
                title: 'Gear Out',
                value: count.toString(),
                subtitle: 'Items',
                icon: Icons.camera_alt,
              );
            },
          ),

          // Bookings Today Count
          ValueListenableBuilder<int>(
            valueListenable: controller.bookingsTodayCount,
            builder: (context, count, _) {
              return _buildSummaryCard(
                title: 'Bookings Today',
                value: count.toString(),
                subtitle: 'Today',
                icon: Icons.event,
              );
            },
          ),

          // Gear Returning Soon Count
          ValueListenableBuilder<int>(
            valueListenable: controller.gearReturningCount,
            builder: (context, count, _) {
              return _buildSummaryCard(
                title: 'Gear Returning',
                value: count.toString(),
                subtitle: 'Soon',
                icon: Icons.assignment_return,
              );
            },
          ),

          // Studio Booking Info
          ValueListenableBuilder<Booking?>(
            valueListenable: controller.studioBookingToday,
            builder: (context, booking, _) {
              return _buildStudioBookingInfo(booking);
            },
          ),
        ],
      ),
    );
  }

  // Build a summary card
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
      child: BLKWDSCard(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BLKWDSIconContainer(
                  icon: icon,
                  size: BLKWDSIconContainerSize.small,
                  backgroundColor: BLKWDSColors.accentTeal,
                  backgroundAlpha: BLKWDSColors.alphaVeryLow,
                  iconColor: BLKWDSColors.accentTeal,
                  // iconSize parameter removed
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                Flexible(
                  child: Text(
                    title,
                    style: BLKWDSTypography.labelMedium.copyWith(
                      color: BLKWDSColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: BLKWDSTypography.headlineLarge.copyWith(
                      color: BLKWDSColors.accentTeal,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                Flexible(
                  child: Text(
                    subtitle,
                    style: BLKWDSTypography.bodySmall.copyWith(
                      color: BLKWDSColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build studio booking info
  Widget _buildStudioBookingInfo(Booking? studioBooking) {
    final isBooked = studioBooking != null && studioBooking.projectId != -1;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
      child: BLKWDSCard(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const BLKWDSIconContainer(
                  icon: Icons.business,
                  size: BLKWDSIconContainerSize.small,
                  backgroundColor: BLKWDSColors.accentTeal,
                  backgroundAlpha: BLKWDSColors.alphaVeryLow,
                  iconColor: BLKWDSColors.accentTeal,
                  // iconSize parameter removed
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                Flexible(
                  child: Text(
                    'Studio:',
                    style: BLKWDSTypography.labelMedium.copyWith(
                      color: BLKWDSColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            BLKWDSStatusBadge(
              text: isBooked ? 'BOOKED' : 'AVAILABLE',
              color: isBooked
                  ? BLKWDSColors.statusOut
                  : BLKWDSColors.statusIn,
              icon: isBooked ? Icons.event_busy : Icons.event_available,
            ),
            if (isBooked)
              Text(
                _formatStudioTime(studioBooking),
                style: BLKWDSTypography.bodySmall.copyWith(
                  color: BLKWDSColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Format studio booking time
  String _formatStudioTime(Booking booking) {
    final startTime = TimeOfDay.fromDateTime(booking.startDate);
    final endTime = TimeOfDay.fromDateTime(booking.endDate);

    return '${_formatTimeOfDay(startTime)} – ${_formatTimeOfDay(endTime)}';
  }

  // Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    // Use 12-hour format with AM/PM
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
