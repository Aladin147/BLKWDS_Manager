import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';

import 'booking_panel_controller.dart';
import 'widgets/booking_filter_bar.dart';
import 'widgets/booking_form.dart';
import 'widgets/booking_list_item.dart';
import 'widgets/calendar_view.dart';
import 'widgets/booking_details_modal.dart';

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

  // Show booking form
  bool _showBookingForm = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Initialize data
  Future<void> _initializeData() async {
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
          BookingForm(
            controller: _controller,
            booking: _selectedBooking,
            onSave: _saveBooking,
            onCancel: _hideBookingForm,
          ),
        ],
      ),
    );
  }

  // Build list view
  Widget _buildListView() {
    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: BookingFilterBar(
            controller: _controller,
            onFilterChanged: () {
              // Refresh the UI when filters change
              setState(() {});
            },
          ),
        ),

        // Booking list
        Expanded(
          child: ValueListenableBuilder<List<Booking>>(
            valueListenable: _controller.filteredBookingList,
            builder: (context, filteredBookings, child) {
              if (_controller.bookingList.value.isEmpty) {
                // No bookings at all
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: BLKWDSColors.slateGrey,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingMedium),
                      Text(
                        'No bookings yet',
                        style: BLKWDSTypography.titleMedium,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingSmall),
                      Text(
                        'Create a booking to get started',
                        style: BLKWDSTypography.bodyMedium,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingMedium),
                      BLKWDSButton(
                        label: 'Create Booking',
                        icon: Icons.add,
                        type: BLKWDSButtonType.primary,
                        onPressed: _showCreateBookingForm,
                      ),
                    ],
                  ),
                );
              } else if (filteredBookings.isEmpty) {
                // Bookings exist but none match the current filter
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.filter_alt_off,
                        size: 64,
                        color: BLKWDSColors.slateGrey,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingMedium),
                      Text(
                        'No bookings match your filters',
                        style: BLKWDSTypography.titleMedium,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingSmall),
                      Text(
                        'Try adjusting your filter criteria',
                        style: BLKWDSTypography.bodyMedium,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingMedium),
                      BLKWDSButton(
                        label: 'Reset Filters',
                        icon: Icons.clear_all,
                        type: BLKWDSButtonType.secondary,
                        onPressed: () {
                          _controller.resetFilters();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              }

              // Show filtered bookings
              return ListView.builder(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final booking = filteredBookings[index];

                  return BookingListItem(
                    booking: booking,
                    controller: _controller,
                    onEdit: () => _showEditBookingForm(booking),
                    onDelete: () => _deleteBooking(booking),
                  );
                },
              );
            },
          ),
        ),
      ],
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
          _selectedBooking = Booking(
            projectId: _controller.projectList.value.isNotEmpty
                ? _controller.projectList.value.first.id!
                : 0,
            startDate: DateTime(
              day.year,
              day.month,
              day.day,
              DateTime.now().hour,
              0,
            ),
            endDate: DateTime(
              day.year,
              day.month,
              day.day,
              DateTime.now().hour + 2,
              0,
            ),
            isRecordingStudio: false,
            isProductionStudio: false,
            gearIds: [],
          );
          _showBookingForm = true;
        });
      },
      onBookingSelected: (booking) {
        // When a booking is selected, show the booking details modal
        _showBookingDetailsModal(booking);
      },
      onBookingRescheduled: _handleBookingReschedule,
    );
  }

  // Handle booking rescheduling
  void _handleBookingReschedule(Booking booking, DateTime newStartDate) async {
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

  // Show booking details modal
  void _showBookingDetailsModal(Booking booking) {
    final project = _controller.getProjectById(booking.projectId);

    // Get assigned members
    final members = _controller.memberList.value;

    // Get gear items
    final gear = _controller.gearList.value
        .where((g) => booking.gearIds.contains(g.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => BookingDetailsModal(
        booking: booking,
        project: project,
        members: members,
        gear: gear,
        onEdit: () => _showEditBookingForm(booking),
        onDelete: () => _deleteBooking(booking),
      ),
    );
  }
}
