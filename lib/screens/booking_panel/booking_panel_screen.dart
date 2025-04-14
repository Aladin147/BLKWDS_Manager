import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../utils/constants.dart';
import 'booking_panel_controller.dart';
import 'widgets/booking_form.dart';
import 'widgets/booking_list_item.dart';

/// BookingPanelScreen
/// Screen for managing bookings
class BookingPanelScreen extends StatefulWidget {
  const BookingPanelScreen({Key? key}) : super(key: key);

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
              backgroundColor: BLKWDSColors.blkwdsGreen,
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
    return ValueListenableBuilder<List<Booking>>(
      valueListenable: _controller.bookingList,
      builder: (context, bookings, child) {
        if (bookings.isEmpty) {
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
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create Booking'),
                  onPressed: _showCreateBookingForm,
                ),
              ],
            ),
          );
        }
        
        // Sort bookings by start date (newest first)
        final sortedBookings = List<Booking>.from(bookings)
          ..sort((a, b) => b.startDate.compareTo(a.startDate));
        
        return ListView.builder(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          itemCount: sortedBookings.length,
          itemBuilder: (context, index) {
            final booking = sortedBookings[index];
            
            return BookingListItem(
              booking: booking,
              controller: _controller,
              onEdit: () => _showEditBookingForm(booking),
              onDelete: () => _deleteBooking(booking),
            );
          },
        );
      },
    );
  }

  // Build calendar view
  Widget _buildCalendarView() {
    // TODO: Implement calendar view
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_month,
            size: 64,
            color: BLKWDSColors.slateGrey,
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
          Text(
            'Calendar View',
            style: BLKWDSTypography.titleMedium,
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          Text(
            'Calendar view will be implemented in a future update',
            style: BLKWDSTypography.bodyMedium,
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
          ElevatedButton.icon(
            icon: const Icon(Icons.list),
            label: const Text('Switch to List View'),
            onPressed: () {
              setState(() {
                _isCalendarView = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
