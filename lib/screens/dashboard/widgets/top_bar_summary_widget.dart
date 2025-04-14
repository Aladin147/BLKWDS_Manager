import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
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
        vertical: BLKWDSConstants.spacingSmall,
      ),
      decoration: const BoxDecoration(
        color: BLKWDSColors.blkwdsGreen,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    return Container(
      width: 160,
      padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
      decoration: BoxDecoration(
        color: BLKWDSColors.white,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: BLKWDSColors.deepBlack.withValues(alpha: 50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: BLKWDSColors.blkwdsGreen,
                size: 20,
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              Text(
                title,
                style: BLKWDSTypography.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: BLKWDSTypography.headlineLarge.copyWith(
                  color: BLKWDSColors.blkwdsGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              Text(
                subtitle,
                style: BLKWDSTypography.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build studio booking info
  Widget _buildStudioBookingInfo() {
    final studioBooking = _getStudioBookingToday();
    
    return Container(
      width: 160,
      padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
      decoration: BoxDecoration(
        color: BLKWDSColors.white,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: BLKWDSColors.deepBlack.withValues(alpha: 50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business,
                color: BLKWDSColors.blkwdsGreen,
                size: 20,
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              Text(
                'Studio:',
                style: BLKWDSTypography.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          Text(
            studioBooking != null ? 'Booked' : 'Available',
            style: BLKWDSTypography.bodyMedium.copyWith(
              color: studioBooking != null 
                  ? BLKWDSColors.mustardOrange 
                  : BLKWDSColors.electricMint,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (studioBooking != null)
            Text(
              _formatStudioTime(studioBooking),
              style: BLKWDSTypography.bodySmall,
            ),
        ],
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
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
