import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../services/snackbar_service.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../booking_panel_controller.dart';

import 'calendar_booking_item.dart';
import 'calendar_view_adapter.dart';

/// CalendarView
/// Widget for displaying bookings in a calendar format
/// Works with both Booking and BookingV2 models
class CalendarView extends StatefulWidget {
  final BookingPanelController controller;
  final Function(DateTime) onDaySelected;
  final Function(dynamic) onBookingSelected;
  final Function(dynamic, DateTime)? onBookingRescheduled;

  const CalendarView({
    super.key,
    required this.controller,
    required this.onDaySelected,
    required this.onBookingSelected,
    this.onBookingRescheduled,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late ValueNotifier<List<dynamic>> _selectedBookings;
  late CalendarViewAdapter _adapter;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedBookings = ValueNotifier<List<dynamic>>([]);

    // Initialize adapter
    _adapter = CalendarViewAdapter(
      controller: widget.controller,
    );

    // Initialize selected bookings
    _updateSelectedBookings();
  }

  @override
  void dispose() {
    _selectedBookings.dispose();
    super.dispose();
  }

  // Update selected bookings based on selected day
  Future<void> _updateSelectedBookings() async {
    _selectedBookings.value = await _adapter.getBookingsForDay(_selectedDay);
  }

  // Get bookings for a specific day
  Future<List<dynamic>> _getBookingsForDay(DateTime day) async {
    return await _adapter.getBookingsForDay(day);
  }

  // Handle booking drop for rescheduling
  void _handleBookingDrop(dynamic booking, DateTime newDay) async {
    // First check for conflicts
    final noConflicts = await _checkBookingConflicts(booking, newDay);

    // Check if the widget is still mounted before showing snackbar
    if (!mounted) return;

    if (!noConflicts) {
      // Show a snackbar message if there are conflicts
      SnackbarService.showError(context, 'Cannot reschedule: conflicts with existing bookings');
      return;
    }

    // Create a new start date with the same time as the original booking
    final startDate = booking.startDate;
    final newStartDate = DateTime(
      newDay.year,
      newDay.month,
      newDay.day,
      startDate.hour,
      startDate.minute,
    );

    // Call the onBookingRescheduled callback if provided
    if (widget.onBookingRescheduled != null) {
      widget.onBookingRescheduled!(booking, newStartDate);
    }
  }

  // Check if a booking can be dropped on a specific day
  bool _canDropBookingOnDay(dynamic booking, DateTime day) {
    // For now, we'll accept all drops and check conflicts in the handler
    // This is because onWillAcceptWithDetails doesn't support async operations
    return true;
  }

  // Check for booking conflicts before actually rescheduling
  Future<bool> _checkBookingConflicts(dynamic booking, DateTime day) async {
    // Get start and end dates
    final startDate = booking.startDate;
    final endDate = booking.endDate;

    // Create a new start date with the same time as the original booking
    final newStartDate = DateTime(
      day.year,
      day.month,
      day.day,
      startDate.hour,
      startDate.minute,
    );

    // Calculate the duration of the original booking
    final duration = endDate.difference(startDate);

    // Create a new end date based on the new start date and the original duration
    final newEndDate = newStartDate.add(duration);

    // Create a new booking with the updated dates and check for conflicts
    final rescheduledBooking = booking.copyWith(
      startDate: newStartDate,
      endDate: newEndDate,
    );
    return !await _adapter.hasBookingConflicts(rescheduledBooking, excludeBookingId: booking.id);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      children: [
        // Calendar header with view toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingMedium),
          child: Row(
            children: [
              // View toggle
              SegmentedButton<CalendarFormat>(
                segments: const [
                  ButtonSegment<CalendarFormat>(
                    value: CalendarFormat.month,
                    label: Text('Month'),
                    icon: Icon(Icons.calendar_view_month),
                  ),
                  ButtonSegment<CalendarFormat>(
                    value: CalendarFormat.week,
                    label: Text('Week'),
                    icon: Icon(Icons.calendar_view_week),
                  ),
                  ButtonSegment<CalendarFormat>(
                    value: CalendarFormat.twoWeeks,
                    label: Text('2 Weeks'),
                    icon: Icon(Icons.calendar_view_day),
                  ),
                ],
                selected: {_calendarFormat},
                onSelectionChanged: (Set<CalendarFormat> formats) {
                  setState(() {
                    _calendarFormat = formats.first;
                  });
                },
              ),
              const Spacer(),
              // Today button
              TextButton.icon(
                icon: const Icon(Icons.today),
                label: const Text('Today'),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                    _updateSelectedBookings();
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Calendar with enhanced drag-and-drop support
        TableCalendar<dynamic>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: (day) {
            // We need to return a synchronous result for TableCalendar
            // So we'll return an empty list and update it later
            _getBookingsForDay(day).then((bookings) {
              if (isSameDay(day, _selectedDay)) {
                _selectedBookings.value = bookings;
              }
            });
            return [];
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: const BoxDecoration(
              color: BLKWDSColors.electricMint,
              shape: BoxShape.circle,
            ),
            todayDecoration: const BoxDecoration(
              color: BLKWDSColors.blkwdsGreen,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: BLKWDSColors.mustardOrange,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: BLKWDSTypography.titleMedium,
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: BLKWDSColors.slateGrey,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: BLKWDSColors.slateGrey,
            ),
          ),
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _updateSelectedBookings();
            });
            widget.onDaySelected(selectedDay);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          // Custom calendar builder for drag-and-drop support
          calendarBuilders: CalendarBuilders(
            // Custom day builder to make each day a drop target
            defaultBuilder: (context, day, focusedDay) {
              return DragTarget<Object>(
                onAcceptWithDetails: (details) {
                  // Handle the dropped booking
                  _handleBookingDrop(details.data, day);
                },
                onWillAcceptWithDetails: (details) {
                  // Check if the booking can be dropped on this day
                  return _canDropBookingOnDay(details.data, day);
                },
                builder: (context, candidateData, rejectedData) {
                  // Show a visual indicator when a booking is being dragged over a day
                  final isAccepting = candidateData.isNotEmpty;

                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isAccepting ? BLKWDSColors.electricMint.withValues(alpha: 50) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isAccepting
                        ? Border.all(color: BLKWDSColors.electricMint, width: 2)
                        : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: BLKWDSTypography.bodyMedium.copyWith(
                          color: isAccepting ? BLKWDSColors.deepBlack : null,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            // Custom today builder to make today a drop target
            todayBuilder: (context, day, focusedDay) {
              return DragTarget<Object>(
                onAcceptWithDetails: (details) {
                  // Handle the dropped booking
                  _handleBookingDrop(details.data, day);
                },
                onWillAcceptWithDetails: (details) {
                  // Check if the booking can be dropped on this day
                  return _canDropBookingOnDay(details.data, day);
                },
                builder: (context, candidateData, rejectedData) {
                  // Show a visual indicator when a booking is being dragged over a day
                  final isAccepting = candidateData.isNotEmpty;

                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isAccepting
                        ? BLKWDSColors.electricMint.withValues(alpha: 50)
                        : BLKWDSColors.blkwdsGreen,
                      borderRadius: BorderRadius.circular(8),
                      border: isAccepting
                        ? Border.all(color: BLKWDSColors.electricMint, width: 2)
                        : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: BLKWDSTypography.bodyMedium.copyWith(
                          color: BLKWDSColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            // Custom selected day builder to make selected day a drop target
            selectedBuilder: (context, day, focusedDay) {
              return DragTarget<Object>(
                onAcceptWithDetails: (details) {
                  // Handle the dropped booking
                  _handleBookingDrop(details.data, day);
                },
                onWillAcceptWithDetails: (details) {
                  // Check if the booking can be dropped on this day
                  return _canDropBookingOnDay(details.data, day);
                },
                builder: (context, candidateData, rejectedData) {
                  // Show a visual indicator when a booking is being dragged over a day
                  final isAccepting = candidateData.isNotEmpty;

                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isAccepting
                        ? BLKWDSColors.electricMint.withValues(alpha: 50)
                        : BLKWDSColors.mustardOrange,
                      borderRadius: BorderRadius.circular(8),
                      border: isAccepting
                        ? Border.all(color: BLKWDSColors.electricMint, width: 2)
                        : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: BLKWDSTypography.bodyMedium.copyWith(
                          color: BLKWDSColors.deepBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Selected day bookings
        Expanded(
          child: ValueListenableBuilder<List<dynamic>>(
            valueListenable: _selectedBookings,
            builder: (context, bookings, _) {
              if (bookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_available,
                        size: 64,
                        color: BLKWDSColors.slateGrey,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingMedium),
                      Text(
                        'No bookings on ${DateFormat.yMMMMd().format(_selectedDay)}',
                        style: BLKWDSTypography.titleMedium,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingSmall),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create Booking'),
                        onPressed: () => widget.onDaySelected(_selectedDay),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingMedium),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final projectId = booking.projectId;
                  final project = _adapter.getProjectById(projectId);

                  return CalendarBookingItem(
                    booking: booking,
                    project: project,
                    adapter: _adapter,
                    onTap: () => widget.onBookingSelected(booking),
                    onReschedule: widget.onBookingRescheduled,
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
    );
  }
}
