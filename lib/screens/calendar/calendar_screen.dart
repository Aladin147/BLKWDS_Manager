import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/navigation_service.dart';
import '../../services/snackbar_service.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';
import '../booking_panel/widgets/booking_details_modal.dart';
import 'calendar_controller.dart';
import 'widgets/calendar_filter_panel.dart';
import 'widgets/calendar_booking_list.dart';

/// CalendarScreen
/// Screen for viewing all bookings in a calendar format
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Controller
  final _controller = CalendarController();

  // Calendar state
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late ValueNotifier<List<Booking>> _selectedDayBookings;

  // UI state
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedDayBookings = ValueNotifier<List<Booking>>([]);

    // Set the context for error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setContext(context);
    });

    // Initialize data
    _initializeData();

    // Add listeners for filter changes
    _addFilterListeners();
  }

  // Initialize data
  Future<void> _initializeData() async {
    try {
      await _controller.initialize();
      _updateSelectedDayBookings();
    } catch (e) {
      // Handle the case where the controller is disposed
      if (mounted) {
        _showSnackBar('Error refreshing calendar data');
      }
    }
  }

  // Add listeners for filter changes
  void _addFilterListeners() {
    _controller.selectedProjectId.addListener(_updateSelectedDayBookings);
    _controller.selectedMemberId.addListener(_updateSelectedDayBookings);
    _controller.selectedGearId.addListener(_updateSelectedDayBookings);
    _controller.filterStartDate.addListener(_updateSelectedDayBookings);
    _controller.filterEndDate.addListener(_updateSelectedDayBookings);
  }

  // Update selected day bookings
  void _updateSelectedDayBookings() {
    try {
      if (mounted) {
        _selectedDayBookings.value = _controller.getBookingsForDay(_selectedDay);
      }
    } catch (e) {
      // Handle the case where the notifier is disposed
    }
  }

  // Get bookings for a day (for calendar event loader)
  List<Booking> _getBookingsForDay(DateTime day) {
    return _controller.getBookingsForDay(day);
  }

  // Show booking details
  void _showBookingDetails(Booking booking) {
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
        onEdit: () {
          Navigator.pop(context);
          _navigateToBookingPanel(booking);
        },
        onDelete: () {
          Navigator.pop(context);
          _showSnackBar('To delete bookings, please use the Booking Panel');
        },
      ),
    );
  }

  // Navigate to booking panel for editing
  void _navigateToBookingPanel(Booking booking) {
    NavigationService.instance.navigateToBookingPanel().then((_) {
      // Refresh data when returning from booking panel
      _initializeData();
    });
  }

  // Show a snackbar message
  void _showSnackBar(String message) {
    SnackbarService.showInfo(context, message, duration: BLKWDSConstants.toastDuration);
  }

  @override
  void dispose() {
    _selectedDayBookings.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BLKWDSColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          // Filter toggle
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          // Create booking button
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Booking',
            onPressed: () {
              NavigationService.instance.navigateToBookingPanel().then((_) {
                // Refresh data when returning from booking panel
                _initializeData();
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

          return Column(
            children: [
              // Filter panel (collapsible)
              if (_showFilters)
                CalendarFilterPanel(
                  controller: _controller,
                  onResetFilters: () {
                    _controller.resetFilters();
                  },
                ),

              // Calendar header with view toggle
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.spacingMedium,
                  vertical: BLKWDSConstants.spacingSmall,
                ),
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
                    BLKWDSButton(
                      label: 'Today',
                      icon: Icons.today,
                      type: BLKWDSButtonType.secondary,
                      isSmall: true,
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime.now();
                          _selectedDay = DateTime.now();
                          _updateSelectedDayBookings();
                        });
                      },
                    ),
                  ],
                ),
              ),

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
                    color: BLKWDSColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: BLKWDSColors.accentTeal,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: BLKWDSColors.warningAmber,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: BLKWDSTypography.titleMedium.copyWith(
                    color: BLKWDSColors.textPrimary,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: BLKWDSColors.textSecondary,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: BLKWDSColors.textSecondary,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _updateSelectedDayBookings();
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),

              // Selected day header
              Padding(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                child: Row(
                  children: [
                    Text(
                      DateFormat.yMMMMd().format(_selectedDay),
                      style: BLKWDSTypography.titleMedium.copyWith(
                      color: BLKWDSColors.textPrimary,
                    ),
                    ),
                    const Spacer(),
                    ValueListenableBuilder<List<Booking>>(
                      valueListenable: _selectedDayBookings,
                      builder: (context, bookings, _) {
                        return Text(
                          '${bookings.length} booking${bookings.length != 1 ? 's' : ''}',
                          style: BLKWDSTypography.bodyMedium.copyWith(
                            color: BLKWDSColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bookings for selected day
              Expanded(
                child: CalendarBookingList(
                  bookingsNotifier: _selectedDayBookings,
                  controller: _controller,
                  onBookingTap: _showBookingDetails,
                  onCreateBooking: () {
                    NavigationService.instance.navigateToBookingPanel().then((_) {
                      // Refresh data when returning from booking panel
                      _initializeData();
                    });
                  },
                  selectedDay: _selectedDay,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
