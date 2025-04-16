import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../booking_panel_controller.dart';
import 'booking_form.dart';

/// BookingFormAdapter
/// Adapter component that connects Booking models with the BookingForm component
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
    return BookingForm(
      controller: controller,
      booking: booking,
      onSave: onSave,
      onCancel: onCancel,
    );
  }
}
