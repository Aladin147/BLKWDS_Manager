import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'booking_detail_screen_v2.dart';
import 'booking_panel_controller.dart';

/// BookingDetailScreenAdapter
/// Displays the booking detail screen
class BookingDetailScreenAdapter extends StatelessWidget {
  final Booking booking;
  final BookingPanelController controller;

  const BookingDetailScreenAdapter({
    super.key,
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BookingDetailScreenV2(
      booking: booking,
      controller: controller,
    );
  }
}
