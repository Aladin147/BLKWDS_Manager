# Calendar Drag-and-Drop Functionality

## Overview

The BLKWDS Manager application includes a calendar view for visualizing and managing bookings. The drag-and-drop functionality allows users to reschedule bookings by dragging them to a new date on the calendar.

## Implementation Details

### Components

1. **CalendarView**: The main calendar component that displays days and bookings.
   - Each day in the calendar is a drop target for booking items.
   - Visual feedback is provided when dragging over valid drop targets.
   - Conflict detection prevents dropping bookings on days with conflicts.

2. **CalendarBookingItem**: Represents a booking in the calendar.
   - Implements `Draggable<Booking>` to make bookings draggable.
   - Provides visual feedback during drag operations.
   - Shows a placeholder in the original location during dragging.

3. **BookingPanelController**: Handles the business logic for booking operations.
   - Provides methods for checking booking conflicts.
   - Implements the rescheduling logic.

### Drag-and-Drop Process

1. **Initiate Drag**: User starts dragging a booking from its current position.
   - The booking item shows a visual placeholder in its original location.
   - A draggable representation of the booking appears under the cursor.

2. **Drag Over Days**: As the user drags over calendar days:
   - Valid drop targets (days without conflicts) show visual feedback.
   - The day changes appearance to indicate it's a potential drop target.

3. **Drop**: When the user drops the booking on a day:
   - The system checks for conflicts with existing bookings.
   - If no conflicts exist, the booking is rescheduled to the new date.
   - If conflicts exist, the operation is canceled and an error message is shown.

4. **Confirmation**: A confirmation dialog appears before finalizing the reschedule.
   - The user can confirm or cancel the rescheduling operation.
   - Upon confirmation, the booking is updated in the database.

### Conflict Detection

The system checks for the following conflicts when rescheduling a booking:

1. **Gear Conflicts**: If any gear in the booking is already booked for the new time slot.
2. **Studio Conflicts**: If the recording or production studio is already booked for the new time slot.
3. **Time Conflicts**: If the booking overlaps with existing bookings for the same resources.

### Visual Feedback

The drag-and-drop implementation includes several visual cues:

1. **Drag Feedback**: A stylized representation of the booking appears under the cursor during dragging.
2. **Original Location**: A placeholder appears in the original location to indicate the booking is being moved.
3. **Drop Target Highlight**: Valid drop targets are highlighted when dragged over.
4. **Error Feedback**: If a booking cannot be dropped on a day, visual feedback indicates the invalid operation.

## Usage

To reschedule a booking using drag-and-drop:

1. Navigate to the Calendar View in the Booking Panel.
2. Find the booking you want to reschedule.
3. Click and drag the booking to a new date.
4. If the new date is valid (no conflicts), confirm the rescheduling in the dialog.
5. The booking will be updated with the new date while preserving its duration.

## Future Enhancements

Potential future enhancements to the drag-and-drop functionality:

1. **Time Slot Dragging**: Allow dragging to specific time slots, not just days.
2. **Multi-day Dragging**: Enhance support for multi-day bookings.
3. **Resize Handles**: Add the ability to resize bookings to change their duration.
4. **Drag Preview**: Show a preview of the booking in the target location before dropping.
5. **Keyboard Modifiers**: Use keyboard modifiers for additional actions (e.g., copy instead of move).
