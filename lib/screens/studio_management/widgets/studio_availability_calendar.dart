import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/models.dart';
import '../../../services/db_service.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';

/// StudioAvailabilityCalendar
/// Calendar view showing studio availability
class StudioAvailabilityCalendar extends StatefulWidget {
  final List<Studio> studios;
  final StudioSettings settings;

  const StudioAvailabilityCalendar({
    super.key,
    required this.studios,
    required this.settings,
  });

  @override
  State<StudioAvailabilityCalendar> createState() => _StudioAvailabilityCalendarState();
}

class _StudioAvailabilityCalendarState extends State<StudioAvailabilityCalendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late int _selectedStudioId;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedStudioId = widget.studios.isNotEmpty ? widget.studios.first.id! : -1;
    _loadBookings();
  }

  /// Load bookings for the selected studio
  Future<void> _loadBookings() async {
    if (_selectedStudioId == -1) {
      setState(() {
        _bookings = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get bookings for the selected studio
      // This is a placeholder - we'll need to implement this method in DBService
      final bookings = await _getBookingsForStudio(_selectedStudioId);

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        BLKWDSSnackbar.show(
          context: context,
          message: 'Error loading bookings: $e',
          type: BLKWDSSnackbarType.error,
        );
      }
    }
  }

  /// Get bookings for a studio
  Future<List<Booking>> _getBookingsForStudio(int studioId) async {
    return await DBService.getBookingsForStudio(studioId);
  }

  /// Check if a day has bookings
  bool _hasBookingsOnDay(DateTime day) {
    return _bookings.any((booking) {
      final bookingStart = DateTime(
        booking.startDate.year,
        booking.startDate.month,
        booking.startDate.day,
      );
      final bookingEnd = DateTime(
        booking.endDate.year,
        booking.endDate.month,
        booking.endDate.day,
      );
      final checkDay = DateTime(day.year, day.month, day.day);

      return (checkDay.isAtSameMomentAs(bookingStart) || checkDay.isAfter(bookingStart)) &&
             (checkDay.isAtSameMomentAs(bookingEnd) || checkDay.isBefore(bookingEnd));
    });
  }

  /// Get bookings for a specific day
  List<Booking> _getBookingsForDay(DateTime day) {
    final checkDay = DateTime(day.year, day.month, day.day);

    return _bookings.where((booking) {
      final bookingStart = DateTime(
        booking.startDate.year,
        booking.startDate.month,
        booking.startDate.day,
      );
      final bookingEnd = DateTime(
        booking.endDate.year,
        booking.endDate.month,
        booking.endDate.day,
      );

      return (checkDay.isAtSameMomentAs(bookingStart) || checkDay.isAfter(bookingStart)) &&
             (checkDay.isAtSameMomentAs(bookingEnd) || checkDay.isBefore(bookingEnd));
    }).toList();
  }

  /// Check if a day is fully booked
  bool _isDayFullyBooked(DateTime day, List<Booking> bookingsOnDay) {
    // If there are no bookings, the day is not fully booked
    if (bookingsOnDay.isEmpty) {
      return false;
    }

    // Get the studio settings
    final settings = widget.settings;

    // If overlapping bookings are allowed, the day is never fully booked
    if (settings.allowOverlappingBookings) {
      return false;
    }

    // Get the operating hours for the day
    final openingTime = settings.openingTime;
    final closingTime = settings.closingTime;

    // Convert to minutes since midnight for easier comparison
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;
    final totalAvailableMinutes = closingMinutes - openingMinutes;

    // Calculate the total booked minutes
    int totalBookedMinutes = 0;

    for (final booking in bookingsOnDay) {
      // Get the start and end times for this booking on this day
      final bookingStart = booking.startDate;
      final bookingEnd = booking.endDate;

      // Convert to the same day if the booking spans multiple days
      final startTimeOnDay = DateTime(
        day.year,
        day.month,
        day.day,
        bookingStart.hour,
        bookingStart.minute,
      );

      final endTimeOnDay = DateTime(
        day.year,
        day.month,
        day.day,
        bookingEnd.hour,
        bookingEnd.minute,
      );

      // Calculate the duration in minutes
      final durationMinutes = endTimeOnDay.difference(startTimeOnDay).inMinutes;

      // Add to the total
      totalBookedMinutes += durationMinutes;
    }

    // Add cleanup time between bookings
    totalBookedMinutes += (bookingsOnDay.length - 1) * settings.cleanupTime;

    // Check if the total booked minutes exceeds the available minutes
    return totalBookedMinutes >= totalAvailableMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      children: [
        // Studio selector and view toggle
        Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: Row(
            children: [
              // Studio selector
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedStudioId,
                  decoration: const InputDecoration(
                    labelText: 'Select Studio',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.studios.map((studio) {
                    return DropdownMenuItem<int>(
                      value: studio.id!,
                      child: Row(
                        children: [
                          Icon(studio.type.icon, size: 20),
                          const SizedBox(width: BLKWDSConstants.spacingSmall),
                          Text(studio.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStudioId = value!;
                    });
                    _loadBookings();
                  },
                ),
              ),

              // Refresh button
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _loadBookings,
              ),
            ],
          ),
        ),

        // Calendar
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: BLKWDSColors.errorRed),
            holidayTextStyle: TextStyle(color: BLKWDSColors.errorRed),
            todayDecoration: BoxDecoration(
              color: BLKWDSColors.accentTeal,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: BLKWDSColors.primaryButtonBackground,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (_hasBookingsOnDay(date)) {
                // Get bookings for this day to determine the marker color
                final bookingsOnDay = _getBookingsForDay(date);

                // Determine if the day is fully booked
                final isFullyBooked = _isDayFullyBooked(date, bookingsOnDay);

                // Choose color based on booking status
                final color = isFullyBooked
                    ? BLKWDSColors.errorRed
                    : BLKWDSColors.primaryButtonBackground;

                return Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),

        // Bookings for selected day
        SizedBox(
          height: 300, // Fixed height to prevent overflow
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBookingsForSelectedDay(),
        ),
      ],
    ),
    );
  }

  /// Build the list of bookings for the selected day
  Widget _buildBookingsForSelectedDay() {
    // Get bookings for the selected day
    final bookingsOnSelectedDay = _getBookingsForDay(_selectedDay);

    // Sort bookings by start time
    bookingsOnSelectedDay.sort((a, b) => a.startDate.compareTo(b.startDate));

    if (bookingsOnSelectedDay.isEmpty) {
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
              'No bookings on ${_formatDate(_selectedDay)}',
              style: BLKWDSTypography.titleMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            Text(
              'This studio is available all day',
              style: BLKWDSTypography.bodyMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            BLKWDSButton(
              label: 'Create Booking',
              icon: Icons.add,
              type: BLKWDSButtonType.primary,
              onPressed: () {
                // Navigate to booking creation screen with pre-selected studio
                _navigateToBookingCreation();
              },
            ),
          ],
        ),
      );
    }

    // Get the studio settings for time display
    final settings = widget.settings;
    final openingTime = settings.openingTime;
    final closingTime = settings.closingTime;

    // Calculate the total minutes in the day for the timeline
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;
    final totalMinutes = closingMinutes - openingMinutes;

    return Column(
      children: [
        // Day header
        Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(_selectedDay),
                style: BLKWDSTypography.titleMedium,
              ),
              Text(
                '${bookingsOnSelectedDay.length} booking${bookingsOnSelectedDay.length != 1 ? 's' : ''}',
                style: BLKWDSTypography.bodyMedium.copyWith(
                  color: BLKWDSColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Timeline header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(TimeOfDay(hour: openingTime.hour, minute: openingTime.minute)),
                style: BLKWDSTypography.labelSmall,
              ),
              Text(
                _formatTime(TimeOfDay(hour: closingTime.hour, minute: closingTime.minute)),
                style: BLKWDSTypography.labelSmall,
              ),
            ],
          ),
        ),

        // Timeline
        Container(
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingMedium),
          decoration: BoxDecoration(
            color: BLKWDSColors.backgroundLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              // Draw booking blocks on the timeline
              for (final booking in bookingsOnSelectedDay)
                Positioned(
                  left: _calculateTimelinePosition(booking.startDate, openingMinutes, totalMinutes),
                  right: _calculateTimelineEndPosition(booking.endDate, openingMinutes, totalMinutes),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: BLKWDSColors.primaryButtonBackground,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Booking list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingMedium),
            itemCount: bookingsOnSelectedDay.length,
            itemBuilder: (context, index) {
              final booking = bookingsOnSelectedDay[index];
              return BLKWDSCard(
                margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
                child: Padding(
                  padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time and duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: BLKWDSColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${_formatTime(TimeOfDay.fromDateTime(booking.startDate))} - ${_formatTime(TimeOfDay.fromDateTime(booking.endDate))}',
                                style: BLKWDSTypography.bodyMedium,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: BLKWDSColors.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatDuration(booking.endDate.difference(booking.startDate)),
                              style: BLKWDSTypography.labelSmall,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: BLKWDSConstants.spacingSmall),

                      // Booking title
                      Text(
                        booking.title ?? 'Untitled Booking',
                        style: BLKWDSTypography.titleMedium,
                      ),

                      const SizedBox(height: BLKWDSConstants.spacingSmall),

                      // Project info
                      FutureBuilder<Project?>(
                        future: _getProjectForBooking(booking),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Loading project...');
                          }

                          final project = snapshot.data;
                          return Text(
                            project?.title ?? 'Unknown Project',
                            style: BLKWDSTypography.bodyMedium.copyWith(
                              color: BLKWDSColors.textSecondary,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: BLKWDSConstants.spacingMedium),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BLKWDSButton(
                            label: 'View Details',
                            icon: Icons.visibility,
                            type: BLKWDSButtonType.secondary,
                            isSmall: true,
                            onPressed: () {
                              // Navigate to booking details
                              _navigateToBookingDetails(booking);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Calculate the position on the timeline for a booking start time
  double _calculateTimelinePosition(DateTime dateTime, int openingMinutes, int totalMinutes) {
    final timeMinutes = dateTime.hour * 60 + dateTime.minute;
    final position = (timeMinutes - openingMinutes) / totalMinutes;
    return position.clamp(0.0, 1.0) * 100.0;
  }

  /// Calculate the end position on the timeline for a booking end time
  double _calculateTimelineEndPosition(DateTime dateTime, int openingMinutes, int totalMinutes) {
    final timeMinutes = dateTime.hour * 60 + dateTime.minute;
    final position = (timeMinutes - openingMinutes) / totalMinutes;
    return (1.0 - position.clamp(0.0, 1.0)) * 100.0;
  }

  /// Get project for a booking
  Future<Project?> _getProjectForBooking(Booking booking) async {
    try {
      return await DBService.getProjectById(booking.projectId);
    } catch (e) {
      return null;
    }
  }

  /// Format time for display
  String _formatTime(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours${hours == 1 ? 'hr' : 'hrs'} ${minutes > 0 ? '$minutes${minutes == 1 ? 'min' : 'mins'}' : ''}';
    } else {
      return '$minutes${minutes == 1 ? 'min' : 'mins'}';
    }
  }

  /// Navigate to booking creation screen
  void _navigateToBookingCreation() {
    // Get the selected studio
    final selectedStudio = widget.studios.firstWhere(
      (studio) => studio.id == _selectedStudioId,
      orElse: () => widget.studios.first,
    );

    // Create a new booking with the selected studio and date
    final newBooking = Booking(
      projectId: -1, // This will be selected in the booking form
      startDate: DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        widget.settings.openingTime.hour,
        widget.settings.openingTime.minute,
      ),
      endDate: DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        widget.settings.openingTime.hour + 1,
        widget.settings.openingTime.minute,
      ),
      studioId: selectedStudio.id,
    );

    // Navigate to the booking panel with the new booking
    Navigator.of(context).pushNamed(
      '/booking_panel',
      arguments: {
        'booking': newBooking,
        'isNew': true,
      },
    );
  }

  /// Navigate to booking details screen
  void _navigateToBookingDetails(Booking booking) {
    // Navigate to the booking details screen
    Navigator.of(context).pushNamed(
      '/booking_detail',
      arguments: {
        'bookingId': booking.id,
      },
    );
  }
}
