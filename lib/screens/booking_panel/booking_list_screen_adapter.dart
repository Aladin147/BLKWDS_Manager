import 'package:flutter/material.dart';
import 'booking_panel_controller.dart';
import 'booking_list_screen.dart';

/// BookingListScreenAdapter
/// Adapter for the BookingListScreen to handle different booking types
class BookingListScreenAdapter extends StatelessWidget {
  /// The controller for the booking panel
  final BookingPanelController controller;
  
  /// Constructor
  const BookingListScreenAdapter({
    super.key,
    required this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return BookingListScreen(
      controller: controller,
    );
  }
}
