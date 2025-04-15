import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../utils/booking_converter.dart';
import '../../../utils/feature_flags.dart';
import '../booking_panel_controller.dart';
import 'booking_form.dart';

/// BookingFormAdapter
/// Adapter component that converts between Booking and BookingV2 models
/// for use with the BookingForm component
class BookingFormAdapter extends StatelessWidget {
  final BookingPanelController controller;
  final Booking? booking; // Null for new booking, non-null for editing
  final Function(Booking) onSave;
  final VoidCallback onCancel;

  const BookingFormAdapter({
    super.key,
    required this.controller,
    this.booking,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BookingV2?>(
      future: booking != null ? BookingConverter.toBookingV2(booking!) : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return BookingForm(
          controller: controller,
          booking: snapshot.data,
          onSave: (bookingV2) async {
            // Convert BookingV2 back to Booking
            final oldBooking = await BookingConverter.toBooking(bookingV2);
            onSave(oldBooking);
          },
          onCancel: onCancel,
        );
      },
    );
  }
}
