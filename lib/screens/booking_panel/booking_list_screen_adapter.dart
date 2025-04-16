import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import 'booking_detail_screen_adapter.dart';
import 'booking_panel_controller_v2.dart';

/// BookingListScreenAdapter
/// Adapter component that routes to the appropriate booking list screen
/// based on the controller type
class BookingListScreenAdapter extends StatelessWidget {
  final dynamic controller;

  const BookingListScreenAdapter({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // We'll use the V2 controller for now
    if (controller is BookingPanelControllerV2) {
      final v2Controller = controller as BookingPanelControllerV2;
      return _buildBookingList(context, v2Controller);
    } else {
      // For other controller types, show a placeholder
      return const Center(
        child: Text('Unsupported controller type'),
      );
    }
  }

  // Build the booking list using the V2 controller
  Widget _buildBookingList(BuildContext context, BookingPanelControllerV2 controller) {
    return ValueListenableBuilder<List<Booking>>(
      valueListenable: controller.bookingList,
      builder: (context, bookings, _) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.event_busy,
                  size: 64,
                  color: BLKWDSColors.slateGrey,
                ),
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                Text(
                  'No Bookings Found',
                  style: BLKWDSTypography.titleLarge,
                ),
                const SizedBox(height: BLKWDSConstants.spacingSmall),
                Text(
                  'Create a new booking to get started',
                  style: BLKWDSTypography.bodyMedium,
                ),
              ],
            ),
          );
        }

        // Sort bookings by start date
        final sortedBookings = List<Booking>.from(bookings);
        sortedBookings.sort((a, b) => a.startDate.compareTo(b.startDate));

        return ListView.builder(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          itemCount: sortedBookings.length,
          itemBuilder: (context, index) {
            final booking = sortedBookings[index];
            final project = controller.getProjectById(booking.projectId);
            final studio = booking.studioId != null ? controller.getStudioById(booking.studioId!) : null;

            return Card(
              margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
              child: ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: controller.getColorForBooking(booking),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(project?.title ?? 'Unknown Project'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat.yMMMd().format(booking.startDate)} ${DateFormat.jm().format(booking.startDate)} - ${DateFormat.jm().format(booking.endDate)}',
                    ),
                    if (studio != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(studio.type.icon, size: 16),
                            const SizedBox(width: 4),
                            Text(studio.name),
                          ],
                        ),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to booking detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreenAdapter(
                        booking: booking,
                        controller: controller,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
