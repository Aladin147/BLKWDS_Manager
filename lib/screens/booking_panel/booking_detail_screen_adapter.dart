import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'booking_detail_screen.dart';
import 'booking_detail_screen_v2.dart';
import 'booking_panel_controller.dart';
import 'booking_panel_controller_v2.dart';

/// BookingDetailScreenAdapter
/// Adapter component that routes to the appropriate booking detail screen
/// based on the controller type
class BookingDetailScreenAdapter extends StatelessWidget {
  final Booking booking;
  final dynamic controller;

  const BookingDetailScreenAdapter({
    super.key,
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller is BookingPanelControllerV2) {
      return BookingDetailScreenV2(
        booking: booking,
        controller: controller as BookingPanelControllerV2,
      );
    } else if (controller is BookingPanelController) {
      return BookingDetailScreen(
        booking: booking,
        controller: controller as BookingPanelController,
      );
    } else {
      throw ArgumentError('Unsupported controller type: ${controller.runtimeType}');
    }
  }
}
