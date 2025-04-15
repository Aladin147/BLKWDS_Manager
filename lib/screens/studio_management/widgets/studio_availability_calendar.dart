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
  List<BookingV2> _bookings = [];
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
  Future<List<BookingV2>> _getBookingsForStudio(int studioId) async {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Studio selector
        Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
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

        // Calendar
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: BLKWDSColors.errorRed),
            holidayTextStyle: TextStyle(color: BLKWDSColors.errorRed),
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
                return Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: BLKWDSColors.primaryButtonBackground,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),

        // Bookings for selected day
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBookingsForSelectedDay(),
        ),
      ],
    );
  }

  /// Build the list of bookings for the selected day
  Widget _buildBookingsForSelectedDay() {
    // Filter bookings for the selected day
    final bookingsOnSelectedDay = _bookings.where((booking) {
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
      final selectedDate = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
      );

      return (selectedDate.isAtSameMomentAs(bookingStart) || selectedDate.isAfter(bookingStart)) &&
             (selectedDate.isAtSameMomentAs(bookingEnd) || selectedDate.isBefore(bookingEnd));
    }).toList();

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
              'No bookings on ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: BLKWDSTypography.titleMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            Text(
              'This studio is available all day',
              style: BLKWDSTypography.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      itemCount: bookingsOnSelectedDay.length,
      itemBuilder: (context, index) {
        final booking = bookingsOnSelectedDay[index];
        return BLKWDSCard(
          margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
          child: ListTile(
            title: Text(booking.title ?? 'Untitled Booking'),
            subtitle: Text(
              '${_formatTime(booking.startDate)} - ${_formatTime(booking.endDate)}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to booking details
            },
          ),
        );
      },
    );
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
