import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../booking_panel_controller.dart';
import 'calendar_booking_item.dart';

/// CalendarView
/// Widget for displaying bookings in a calendar format
class CalendarView extends StatefulWidget {
  final BookingPanelController controller;
  final Function(DateTime) onDaySelected;
  final Function(Booking) onBookingSelected;

  const CalendarView({
    super.key,
    required this.controller,
    required this.onDaySelected,
    required this.onBookingSelected,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late ValueNotifier<List<Booking>> _selectedBookings;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedBookings = ValueNotifier<List<Booking>>([]);

    // Initialize selected bookings
    _updateSelectedBookings();
  }

  @override
  void dispose() {
    _selectedBookings.dispose();
    super.dispose();
  }

  // Update selected bookings based on selected day
  void _updateSelectedBookings() {
    _selectedBookings.value = widget.controller.getBookingsForDay(_selectedDay);
  }

  // Get bookings for a specific day
  List<Booking> _getBookingsForDay(DateTime day) {
    return widget.controller.getBookingsForDay(day);
  }



  @override
  Widget build(BuildContext context) {
    return Column(
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

        // Calendar
        TableCalendar<Booking>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: _getBookingsForDay,
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
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Selected day bookings
        Expanded(
          child: ValueListenableBuilder<List<Booking>>(
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
                  final project = widget.controller.getProjectById(booking.projectId);

                  return CalendarBookingItem(
                    booking: booking,
                    project: project,
                    onTap: () => widget.onBookingSelected(booking),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
