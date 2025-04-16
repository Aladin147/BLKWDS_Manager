import 'package:flutter/material.dart';
import 'booking_list_screen.dart';
import 'booking_panel_controller.dart';
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
    if (controller is BookingPanelControllerV2) {
      return BookingListScreen(
        controller: controller as BookingPanelControllerV2,
      );
    } else if (controller is BookingPanelController) {
      // For now, we'll just use the V2 screen with a V2 controller
      // In the future, we might want to create a V1-specific screen
      final v2Controller = BookingPanelControllerV2();
      return BookingListScreen(
        controller: v2Controller,
      );
    } else {
      throw ArgumentError('Unsupported controller type: ${controller.runtimeType}');
    }
  }
}
