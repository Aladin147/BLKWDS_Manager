import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_shadows.dart';
import '../../../widgets/blkwds_widgets.dart';

import '../booking_panel_controller.dart';
import 'calendar_booking_item.dart';
import 'calendar_view_adapter.dart';

/// CalendarView
/// Widget for displaying bookings in a calendar format
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

  /// Update selected bookings when the selected day changes
  Future<void> _updateSelectedBookings() async {
    final bookings = await _getBookingsForDay(_selectedDay);
    _selectedBookings.value = bookings;
  }

  /// Get bookings for a specific day
  Future<List<dynamic>> _getBookingsForDay(DateTime day) async {
    return await _adapter.getBookingsForDay(day);
  }

  /// Handle booking drop on a day
  Future<void> _handleBookingDrop(dynamic booking, DateTime day) async {
    // Check if the booking can be dropped on this day
    final canDrop = await _canDropBookingOnDay(booking, day);

    if (canDrop && widget.onBookingRescheduled != null) {
      widget.onBookingRescheduled!(booking, day);
    }
  }

  /// Check if a booking can be dropped on a day
  Future<bool> _canDropBookingOnDay(dynamic booking, DateTime day) async {
    // Calculate the new start and end dates
    final duration = booking.endDate.difference(booking.startDate);
    final newStartDate = DateTime(
      day.year,
      day.month,
      day.day,
      booking.startDate.hour,
      booking.startDate.minute,
    );
    final newEndDate = newStartDate.add(duration);

    // Create a new booking with the new dates
    final rescheduledBooking = Booking(
      id: booking.id,
      projectId: booking.projectId,
      title: booking.title,
      startDate: newStartDate,
      endDate: newEndDate,
      studioId: booking.studioId,
      gearIds: booking.gearIds,
      assignedGearToMember: booking.assignedGearToMember,
      color: booking.color,
      notes: booking.notes,
    );

    // Check for conflicts
    return !await _adapter.hasBookingConflicts(rescheduledBooking, excludeBookingId: booking.id);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 600,
        ),
        child: Column(
      children: [
        // Calendar header with view toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingMedium),
          child: Row(
            children: [
              // View toggle
              BLKWDSEnhancedSegmentedButton<CalendarFormat>(
                segments: const [
                  BLKWDSEnhancedSegment<CalendarFormat>(
                    value: CalendarFormat.month,
                    label: 'Month',
                    icon: Icons.calendar_view_month,
                  ),
                  BLKWDSEnhancedSegment<CalendarFormat>(
                    value: CalendarFormat.week,
                    label: 'Week',
                    icon: Icons.calendar_view_week,
                  ),
                  BLKWDSEnhancedSegment<CalendarFormat>(
                    value: CalendarFormat.twoWeeks,
                    label: '2 Weeks',
                    icon: Icons.calendar_view_day,
                  ),
                ],
                selectedValue: _calendarFormat,
                onSegmentSelected: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                primaryColor: BLKWDSColors.blkwdsGreen,
              ),
              const Spacer(),
              // Today button
              BLKWDSEnhancedButton(
                label: 'Today',
                icon: Icons.today,
                type: BLKWDSEnhancedButtonType.secondary,
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
            markerDecoration: BoxDecoration(
              color: BLKWDSColors.electricMint,
              shape: BoxShape.circle,
              boxShadow: BLKWDSShadows.getShadow(BLKWDSShadows.level1),
            ),
            todayDecoration: BoxDecoration(
              color: BLKWDSColors.blkwdsGreen,
              shape: BoxShape.circle,
              boxShadow: BLKWDSShadows.getShadow(BLKWDSShadows.level1),
            ),
            selectedDecoration: BoxDecoration(
              color: BLKWDSColors.mustardOrange,
              shape: BoxShape.circle,
              boxShadow: BLKWDSShadows.getShadow(BLKWDSShadows.level1),
            ),
            weekendTextStyle: const TextStyle(color: BLKWDSColors.accentTeal),
            outsideTextStyle: TextStyle(color: BLKWDSColors.textSecondary.withValues(alpha: 150)),
            defaultTextStyle: const TextStyle(color: BLKWDSColors.textPrimary),
            selectedTextStyle: const TextStyle(color: BLKWDSColors.white, fontWeight: FontWeight.bold),
            todayTextStyle: const TextStyle(color: BLKWDSColors.white, fontWeight: FontWeight.bold),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: BLKWDSColors.blkwdsGreen),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: BLKWDSColors.blkwdsGreen,
              size: 28,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: BLKWDSColors.blkwdsGreen,
              size: 28,
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: BLKWDSConstants.spacingMedium),
            headerMargin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
            decoration: BoxDecoration(
              color: BLKWDSColors.backgroundMedium,
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              boxShadow: BLKWDSShadows.getShadow(BLKWDSShadows.level1),
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
                  // We need a synchronous result, so we'll always accept the drop
                  // and then check for conflicts when the drop happens
                  return true;
                },
                builder: (context, candidateData, rejectedData) {
                  // Show a visual indicator when a booking is being dragged over a day
                  final isAccepting = candidateData.isNotEmpty;

                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isAccepting ? BLKWDSColors.electricMint.withValues(alpha: 50) : null,
                      borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                      border: isAccepting
                        ? Border.all(color: BLKWDSColors.electricMint, width: 2)
                        : null,
                      boxShadow: isAccepting ? BLKWDSShadows.getShadow(BLKWDSShadows.level1) : null,
                    ),
                    child: Center(
                      child: BLKWDSEnhancedText.bodyMedium(
                        '${day.day}',
                        color: isAccepting ? BLKWDSColors.deepBlack : null,
                        isBold: isAccepting,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Selected day bookings
        Container(
          constraints: const BoxConstraints(minHeight: 300),
          margin: const EdgeInsets.symmetric(vertical: BLKWDSConstants.spacingMedium),
          child: ValueListenableBuilder<List<dynamic>>(
            valueListenable: _selectedBookings,
            builder: (context, bookings, _) {
              if (bookings.isEmpty) {
                return BLKWDSEnhancedCard(
                  padding: const EdgeInsets.all(BLKWDSConstants.spacingLarge),
                  animateOnHover: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BLKWDSEnhancedIconContainer(
                        icon: Icons.event_available,
                        size: BLKWDSEnhancedIconContainerSize.large,
                        backgroundColor: BLKWDSColors.backgroundLight,
                        backgroundAlpha: BLKWDSColors.alphaLow,
                        iconColor: BLKWDSColors.slateGrey,
                        hasShadow: true,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingMedium),
                      BLKWDSEnhancedText.titleLarge(
                        'No bookings on ${DateFormat.yMMMMd().format(_selectedDay)}',
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingSmall),
                      BLKWDSEnhancedText.bodyMedium(
                        'Click the button below to create a new booking for this day.',
                        color: BLKWDSColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingMedium),
                      BLKWDSEnhancedButton(
                        label: 'Create Booking',
                        icon: Icons.add,
                        onPressed: () => widget.onDaySelected(_selectedDay),
                        type: BLKWDSEnhancedButtonType.primary,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  for (final booking in bookings)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BLKWDSConstants.spacingMedium,
                        vertical: BLKWDSConstants.spacingSmall,
                      ),
                      child: CalendarBookingItem(
                        booking: booking,
                        project: _adapter.getProjectById(booking.projectId),
                        adapter: _adapter,
                        onTap: () => widget.onBookingSelected(booking),
                        onReschedule: widget.onBookingRescheduled,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    ),
      ),
    );
  }
}
