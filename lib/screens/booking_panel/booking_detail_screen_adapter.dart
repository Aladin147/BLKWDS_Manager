import 'package:flutter/material.dart';
import 'booking_panel_controller.dart';
import 'booking_detail_screen.dart';

/// BookingDetailScreenAdapter
/// Adapter for the BookingDetailScreen to handle different booking types
class BookingDetailScreenAdapter extends StatelessWidget {
  /// The booking to display
  final dynamic booking;

  /// The controller for the booking panel
  final BookingPanelController controller;

  /// Constructor
  const BookingDetailScreenAdapter({
    super.key,
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BookingDetailScreen(
      booking: booking,
      controller: controller,
    );
  }
}
