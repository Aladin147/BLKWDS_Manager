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
          _buildSummaryCard(
            title: 'Gear Out',
            value: _getGearOutCount().toString(),
            subtitle: 'Bookings Today',
            icon: Icons.camera_alt,
          ),

          // Bookings Today Count
          _buildSummaryCard(
            title: 'Bookings Today',
            value: _getBookingsTodayCount().toString(),
            subtitle: 'Today',
            icon: Icons.event,
          ),

          // Gear Returning Soon Count
          _buildSummaryCard(
            title: 'Gear Returning',
            value: _getGearReturningCount().toString(),
            subtitle: 'Soon',
            icon: Icons.assignment_return,
          ),

          // Studio Booking Info
          _buildStudioBookingInfo(),
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
                  iconSize: 20,
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
  Widget _buildStudioBookingInfo() {
    final studioBooking = _getStudioBookingToday();
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
                  iconSize: 20,
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

  // Get count of gear that is currently checked out
  int _getGearOutCount() {
    return controller.gearList.value.where((gear) => gear.isOut).length;
  }

  // Get count of bookings for today
  int _getBookingsTodayCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return controller.bookingList.value.where((booking) {
      final bookingDate = DateTime(
        booking.startDate.year,
        booking.startDate.month,
        booking.startDate.day,
      );
      return bookingDate.isAtSameMomentAs(today);
    }).length;
  }

  // Get count of gear that is returning soon (within the next 24 hours)
  int _getGearReturningCount() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    // Get bookings ending in the next 24 hours
    final returningBookings = controller.bookingList.value.where((booking) {
      return booking.endDate.isAfter(now) && booking.endDate.isBefore(tomorrow);
    }).toList();

    // Count unique gear IDs in these bookings
    final returningGearIds = <int>{};
    for (final booking in returningBookings) {
      returningGearIds.addAll(booking.gearIds);
    }

    return returningGearIds.length;
  }

  // Get studio booking for today
  Booking? _getStudioBookingToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find the first booking today that uses a studio
    return controller.bookingList.value.firstWhere(
      (booking) {
        final bookingDate = DateTime(
          booking.startDate.year,
          booking.startDate.month,
          booking.startDate.day,
        );
        return bookingDate.isAtSameMomentAs(today) &&
               (booking.isRecordingStudio || booking.isProductionStudio);
      },
      orElse: () => Booking(
        projectId: -1,
        title: 'No Studio Booking',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        gearIds: const [],
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
