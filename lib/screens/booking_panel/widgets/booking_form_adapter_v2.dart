import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../booking_panel_controller.dart';
import 'booking_form_v2.dart';

/// BookingFormAdapterV2
/// Adapter component that connects Booking models with the BookingFormV2 component
class BookingFormAdapterV2 extends StatelessWidget {
  final BookingPanelController controller;
  final Booking? booking; // Null for new booking, non-null for editing
  final Function(Booking) onSave;
  final VoidCallback onCancel;

  const BookingFormAdapterV2({
    super.key,
    required this.controller,
    this.booking,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BookingFormV2(
      controller: controller,
      booking: booking,
      onSave: onSave,
      onCancel: onCancel,
    );
  }
}
