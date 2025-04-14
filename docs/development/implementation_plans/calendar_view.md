# Calendar View Implementation Plan

## Overview
The Calendar View will provide a visual representation of all bookings in a monthly calendar format. Users will be able to see bookings by day, week, or month, and quickly identify conflicts or availability. The view will be integrated into the Booking Panel screen as an alternative view to the list view.

## Requirements
- Display bookings in a monthly calendar format
- Allow switching between day, week, and month views
- Color-code bookings based on project or status
- Show booking details on hover/tap
- Allow creating new bookings by clicking on a date
- Support drag-and-drop for rescheduling bookings
- Highlight conflicts or overlapping bookings
- Filter bookings by project, member, or gear

## Technical Approach

### 1. Calendar Widget
We'll use the `table_calendar` package for the base calendar functionality, which provides:
- Month, week, and day views
- Event markers
- Header with navigation controls
- Customizable styling

### 2. Integration with Booking Panel
- Add a toggle in the Booking Panel to switch between list and calendar views
- Use the existing BookingPanelController to manage state
- Implement calendar-specific methods in the controller

### 3. Booking Visualization
- Create a custom CalendarBookingItem widget to display bookings in the calendar
- Implement color-coding based on project or status
- Show booking details in a tooltip or modal

### 4. Interaction
- Implement tap handling to show booking details
- Add long-press or double-tap to edit a booking
- Implement drag-and-drop for rescheduling

### 5. Filtering
- Add filter controls above the calendar
- Implement filtering logic in the BookingPanelController

## Implementation Steps

1. **Setup Calendar Widget**
   - Add `table_calendar` package to pubspec.yaml
   - Create a basic CalendarView widget
   - Integrate with BookingPanelScreen

2. **Connect to Booking Data**
   - Extend BookingPanelController with calendar-specific methods
   - Map bookings to calendar events
   - Implement event loading and filtering

3. **Booking Visualization**
   - Create CalendarBookingItem widget
   - Implement color-coding logic
   - Add booking details tooltip/modal

4. **Interaction**
   - Implement tap handling for booking details
   - Add booking creation on date selection
   - Implement drag-and-drop for rescheduling

5. **Filtering and Navigation**
   - Add filter controls
   - Implement view switching (day/week/month)
   - Add navigation controls (prev/next month)

## UI Components

### CalendarView Widget
```dart
class CalendarView extends StatefulWidget {
  final BookingPanelController controller;
  final Function(DateTime) onDaySelected;
  final Function(Booking) onBookingSelected;

  const CalendarView({
    Key? key,
    required this.controller,
    required this.onDaySelected,
    required this.onBookingSelected,
  }) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}
```

### CalendarBookingItem Widget
```dart
class CalendarBookingItem extends StatelessWidget {
  final Booking booking;
  final Project project;
  final VoidCallback onTap;

  const CalendarBookingItem({
    Key? key,
    required this.booking,
    required this.project,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

### BookingDetailsModal Widget
```dart
class BookingDetailsModal extends StatelessWidget {
  final Booking booking;
  final Project project;
  final List<Member> members;
  final List<Gear> gear;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookingDetailsModal({
    Key? key,
    required this.booking,
    required this.project,
    required this.members,
    required this.gear,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

## Controller Extensions

Add the following methods to BookingPanelController:

```dart
// Get bookings for a specific day
List<Booking> getBookingsForDay(DateTime day) {
  return bookingList.value.where((booking) {
    return booking.startDate.year == day.year &&
           booking.startDate.month == day.month &&
           booking.startDate.day == day.day;
  }).toList();
}

// Get bookings for a date range
List<Booking> getBookingsForRange(DateTime start, DateTime end) {
  return bookingList.value.where((booking) {
    return (booking.startDate.isAfter(start) || 
            booking.startDate.isAtSameMomentAs(start)) &&
           (booking.endDate.isBefore(end) || 
            booking.endDate.isAtSameMomentAs(end));
  }).toList();
}

// Check if a day has any bookings
bool hasBookingsOnDay(DateTime day) {
  return getBookingsForDay(day).isNotEmpty;
}

// Get color for a booking based on project
Color getColorForBooking(Booking booking) {
  // Implementation
}
```

## Testing Plan

1. **Unit Tests**
   - Test BookingPanelController calendar methods
   - Test date range calculations
   - Test booking filtering logic

2. **Widget Tests**
   - Test CalendarView widget rendering
   - Test CalendarBookingItem widget rendering
   - Test interaction handling

3. **Integration Tests**
   - Test calendar navigation
   - Test booking creation from calendar
   - Test booking rescheduling via drag-and-drop
   - Test view switching (day/week/month)

## Dependencies

- `table_calendar`: ^3.0.0 - For the base calendar functionality
- `intl`: ^0.17.0 - For date formatting
- `flutter_slidable`: ^1.2.0 - For swipe actions on booking items (optional)

## Estimated Effort

- Setup Calendar Widget: 1 day
- Connect to Booking Data: 1 day
- Booking Visualization: 1 day
- Interaction: 1-2 days
- Filtering and Navigation: 1 day
- Testing and Refinement: 1-2 days

Total: 6-8 days
