import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';

import 'booking_panel_controller.dart';
import 'booking_panel_controller_v2.dart';
import 'booking_detail_screen_adapter.dart';
import 'booking_list_screen_adapter.dart';

import 'widgets/booking_form_adapter_v2.dart';
import 'widgets/booking_form_v2.dart';
import 'widgets/calendar_view_fixed.dart';

/// BookingPanelScreen
/// Screen for managing bookings
class BookingPanelScreen extends StatefulWidget {
  const BookingPanelScreen({super.key});

  @override
  State<BookingPanelScreen> createState() => _BookingPanelScreenState();
}

class _BookingPanelScreenState extends State<BookingPanelScreen> {
  // Controllers
  final _controller = BookingPanelController();
  BookingPanelControllerV2? _controllerV2;

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
    _initializeData();
  }

  // Initialize data
  Future<void> _initializeData() async {
    // Initialize the V2 controller
    _controllerV2 = BookingPanelControllerV2();
    await _controllerV2!.initialize();

    // Initialize the V1 controller for compatibility
    await _controller.initialize();
  }

  // Show create booking form
  void _showCreateBookingForm() {
    setState(() {
      _selectedBooking = null;
      _showBookingForm = true;
    });
  }

  // Show edit booking form
  void _showEditBookingForm(Booking booking) {
    setState(() {
      _selectedBooking = booking;
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

  // Save booking
  Future<void> _saveBooking(Booking booking) async {
    bool success;

    if (booking.id == null) {
      // Create new booking
      success = await _controller.createBooking(booking);
    } else {
      // Update existing booking
      success = await _controller.updateBooking(booking);
    }

    if (success) {
      _hideBookingForm();
      _showSnackBar(booking.id == null ? 'Booking created' : 'Booking updated');
    } else if (_controller.errorMessage.value != null) {
      _showSnackBar(_controller.errorMessage.value!);
    }
  }

  // Delete booking
  Future<void> _deleteBooking(Booking booking) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: BLKWDSColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _controller.deleteBooking(booking.id!);

      if (success) {
        _showSnackBar('Booking deleted');
      } else if (_controller.errorMessage.value != null) {
        _showSnackBar(_controller.errorMessage.value!);
      }
    }
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
    _controllerV2?.dispose();
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
          BookingFormAdapterV2(
              controller: _controllerV2!,
              booking: _tempBookingV2,
              onSave: (bookingV2) async {
                // Handle BookingV2 save
                final success = await _controllerV2!.createBooking(bookingV2);
                if (success) {
                  _hideBookingForm();
                  _showSnackBar('Booking created successfully');
                } else {
                  _showSnackBar(_controllerV2!.errorMessage.value ?? 'Failed to create booking');
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
      controller: _controllerV2 ?? _controller,
    );
  }

  // Build calendar view
  Widget _buildCalendarView() {
    return CalendarView(
      controller: _controller,
      controllerV2: _controllerV2,
      onDaySelected: (day) {
        // When a day is selected, show the create booking form
        // with the selected day as the start date
        setState(() {
          // Create a BookingV2 object with default values
          final defaultProject = _controllerV2!.projectList.value.isNotEmpty
              ? _controllerV2!.projectList.value.first.id!
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
    if (_controllerV2 != null) {
      await _handleBookingRescheduleV2(booking, newStartDate);
    } else {
      await _handleBookingReschedule(booking, newStartDate);
    }
  }

  // Handle booking rescheduling for BookingV2
  Future<void> _handleBookingRescheduleV2(Booking booking, DateTime newStartDate) async {
    // Show a confirmation dialog
    final project = _controllerV2!.getProjectById(booking.projectId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: Text(
          'Are you sure you want to reschedule "${project?.title ?? 'Unknown Project'}" to ${DateFormat.yMMMd().format(newStartDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reschedule'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      // Show loading indicator
      setState(() {
        _controllerV2!.isLoading.value = true;
      });

      try {
        // Reschedule the booking
        final success = await _controllerV2!.rescheduleBooking(booking, newStartDate);

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
              content: Text(_controllerV2!.errorMessage.value ?? 'Failed to reschedule booking'),
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
          _controllerV2!.isLoading.value = false;
        });
      }
    }
  }

  // Handle booking rescheduling for Booking
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reschedule'),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailScreenAdapter(
          booking: booking,
          controller: _controllerV2 ?? _controller,
        ),
      ),
    ).then((result) {
      // Refresh data if booking was updated or deleted
      if (result == true) {
        _controller.initialize();
        _controllerV2?.initialize();
      }
    });
  }
}
