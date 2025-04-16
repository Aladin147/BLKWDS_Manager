import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/navigation_service.dart';
import '../../theme/blkwds_animations.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';

import 'booking_panel_controller.dart';
import 'booking_detail_screen_adapter.dart';
import 'booking_list_screen_adapter.dart';

import 'widgets/booking_form_adapter.dart';

import 'widgets/calendar_view_fixed.dart';

/// BookingPanelScreen
/// Screen for managing bookings
class BookingPanelScreen extends StatefulWidget {
  const BookingPanelScreen({super.key});

  @override
  State<BookingPanelScreen> createState() => _BookingPanelScreenState();
}

class _BookingPanelScreenState extends State<BookingPanelScreen> {
  // Controller
  final _controller = BookingPanelController();

  // View mode
  bool _isCalendarView = false;

  // Selected booking for editing
  Booking? _selectedBooking;
  Booking? _tempBookingV2;

  // Show booking form
  bool _showBookingForm = false;

  @override
  void initState() {
    super.initState();
    // Set the context for error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setContext(context);
    });
    _initializeData();
  }

  // Initialize data
  Future<void> _initializeData() async {
    // Initialize the controller
    await _controller.initialize();
  }

  // Show create booking form
  void _showCreateBookingForm() {
    setState(() {
      _selectedBooking = null;
      _showBookingForm = true;
    });
  }

  // Hide booking form
  void _hideBookingForm() {
    setState(() {
      _showBookingForm = false;
      _selectedBooking = null;
      _tempBookingV2 = null;
    });
  }

  // Show a snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: BLKWDSConstants.toastDuration,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Panel'),
        actions: [
          // Toggle view mode
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            tooltip: _isCalendarView ? 'List View' : 'Calendar View',
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _showBookingForm
              ? _buildBookingForm()
              : _isCalendarView
                  ? _buildCalendarView()
                  : _buildListView();
        },
      ),
      floatingActionButton: !_showBookingForm
          ? FloatingActionButton(
              onPressed: _showCreateBookingForm,
              backgroundColor: BLKWDSColors.primaryButtonBackground,
              foregroundColor: BLKWDSColors.primaryButtonText,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // Build booking form
  Widget _buildBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedBooking == null ? 'Create Booking' : 'Edit Booking',
            style: BLKWDSTypography.titleLarge,
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
          BookingFormAdapter(
              controller: _controller,
              booking: _tempBookingV2,
              onSave: (booking) async {
                // Handle booking save
                bool success;
                if (booking.id == null) {
                  // Create new booking
                  success = await _controller.createBooking(booking);
                  if (success) {
                    _hideBookingForm();
                    _showSnackBar('Booking created successfully');
                  } else {
                    _showSnackBar(_controller.errorMessage.value ?? 'Failed to create booking');
                  }
                } else {
                  // Update existing booking
                  success = await _controller.updateBooking(booking);
                  if (success) {
                    _hideBookingForm();
                    _showSnackBar('Booking updated successfully');
                  } else {
                    _showSnackBar(_controller.errorMessage.value ?? 'Failed to update booking');
                  }
                }
              },
              onCancel: _hideBookingForm,
            ),
        ],
      ),
    );
  }

  // Build list view
  Widget _buildListView() {
    return BookingListScreenAdapter(
      controller: _controller,
    );
  }

  // Build calendar view
  Widget _buildCalendarView() {
    return CalendarView(
      controller: _controller,
      onDaySelected: (day) {
        // When a day is selected, show the create booking form
        // with the selected day as the start date
        setState(() {
          // Create a BookingV2 object with default values
          final defaultProject = _controller.projectList.value.isNotEmpty
              ? _controller.projectList.value.first.id!
              : 0;

          final defaultStartDate = DateTime(
            day.year,
            day.month,
            day.day,
            DateTime.now().hour,
            0,
          );

          final defaultEndDate = defaultStartDate.add(const Duration(hours: 2));

          // We'll create a temporary Booking object and pass it to the form
          _tempBookingV2 = Booking(
            projectId: defaultProject,
            title: 'New Booking',
            startDate: defaultStartDate,
            endDate: defaultEndDate,
            studioId: null, // No studio selected by default
            gearIds: [],
          );

          _showBookingForm = true;
        });
      },
      onBookingSelected: (booking) {
        // When a booking is selected, navigate to booking detail screen
        _navigateToBookingDetail(booking);
      },
      onBookingRescheduled: _handleBookingRescheduleGeneric,
    );
  }

  // Handle booking rescheduling
  void _handleBookingRescheduleGeneric(dynamic booking, DateTime newStartDate) async {
    await _handleBookingReschedule(booking, newStartDate);
  }



  // Handle booking rescheduling
  Future<void> _handleBookingReschedule(Booking booking, DateTime newStartDate) async {
    // Show a confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: Text(
          'Are you sure you want to reschedule "${_controller.getProjectById(booking.projectId)?.title ?? 'Unknown Project'}" to ${DateFormat.yMMMd().format(newStartDate)}?',
        ),
        actions: [
          BLKWDSButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(false),
            type: BLKWDSButtonType.secondary,
          ),
          BLKWDSButton(
            label: 'Reschedule',
            onPressed: () => Navigator.of(context).pop(true),
            type: BLKWDSButtonType.primary,
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      // Show loading indicator
      setState(() {
        _controller.isLoading.value = true;
      });

      try {
        // Reschedule the booking
        final success = await _controller.rescheduleBooking(booking, newStartDate);

        // Check if the widget is still mounted before showing snackbar
        if (!mounted) return;

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking rescheduled successfully'),
              backgroundColor: BLKWDSColors.blkwdsGreen,
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_controller.errorMessage.value ?? 'Failed to reschedule booking'),
              backgroundColor: BLKWDSColors.statusOut,
            ),
          );
        }
      } catch (e) {
        // Check if the widget is still mounted before showing snackbar
        if (!mounted) return;

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: BLKWDSColors.statusOut,
          ),
        );
      } finally {
        // Hide loading indicator
        setState(() {
          _controller.isLoading.value = false;
        });
      }
    }
  }

  // Navigate to booking detail screen
  void _navigateToBookingDetail(dynamic booking) async {
    final result = await NavigationService().navigateTo(
      BookingDetailScreenAdapter(
        booking: booking,
        controller: _controller,
      ),
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );

    // Refresh data if booking was updated or deleted
    if (result == true) {
      _controller.initialize();
    }
  }
}
