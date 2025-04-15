import '../models/models.dart';
import '../services/db_service.dart';

/// BookingConverter
/// Utility class for converting between Booking and BookingV2 models
class BookingConverter {
  /// Convert a Booking to a BookingV2
  /// 
  /// This method converts a Booking object to a BookingV2 object,
  /// mapping the isRecordingStudio and isProductionStudio flags to a studioId.
  /// 
  /// If both flags are true, it will use a hybrid studio.
  /// If only one flag is true, it will use the corresponding studio.
  /// If neither flag is true, studioId will be null.
  static Future<BookingV2> toBookingV2(Booking booking) async {
    // Determine which studio to use based on the flags
    int? studioId;
    
    if (booking.isRecordingStudio && booking.isProductionStudio) {
      // Both studios - find or create a hybrid studio
      studioId = await _findOrCreateStudioByType(StudioType.hybrid);
    } else if (booking.isRecordingStudio) {
      // Recording studio only
      studioId = await _findOrCreateStudioByType(StudioType.recording);
    } else if (booking.isProductionStudio) {
      // Production studio only
      studioId = await _findOrCreateStudioByType(StudioType.production);
    }
    
    // Create and return the BookingV2 object
    return BookingV2(
      id: booking.id,
      projectId: booking.projectId,
      title: booking.title,
      startDate: booking.startDate,
      endDate: booking.endDate,
      studioId: studioId,
      gearIds: booking.gearIds,
      assignedGearToMember: booking.assignedGearToMember,
      color: booking.color,
    );
  }
  
  /// Convert a BookingV2 to a Booking
  /// 
  /// This method converts a BookingV2 object to a Booking object,
  /// mapping the studioId to isRecordingStudio and isProductionStudio flags.
  static Future<Booking> toBooking(BookingV2 bookingV2) async {
    // Default values for studio flags
    bool isRecordingStudio = false;
    bool isProductionStudio = false;
    
    // If there's a studio, determine the flags based on its type
    if (bookingV2.studioId != null) {
      final studio = await DBService.getStudioById(bookingV2.studioId!);
      
      if (studio != null) {
        switch (studio.type) {
          case StudioType.recording:
            isRecordingStudio = true;
            break;
          case StudioType.production:
            isProductionStudio = true;
            break;
          case StudioType.hybrid:
            isRecordingStudio = true;
            isProductionStudio = true;
            break;
        }
      }
    }
    
    // Create and return the Booking object
    return Booking(
      id: bookingV2.id,
      projectId: bookingV2.projectId,
      title: bookingV2.title,
      startDate: bookingV2.startDate,
      endDate: bookingV2.endDate,
      isRecordingStudio: isRecordingStudio,
      isProductionStudio: isProductionStudio,
      gearIds: bookingV2.gearIds,
      assignedGearToMember: bookingV2.assignedGearToMember,
      color: bookingV2.color,
    );
  }
  
  /// Find a studio by type or create it if it doesn't exist
  static Future<int?> _findOrCreateStudioByType(StudioType type) async {
    try {
      // Get all studios
      final studios = await DBService.getAllStudios();
      
      // Look for a studio of the specified type
      for (final studio in studios) {
        if (studio.type == type && studio.id != null) {
          return studio.id;
        }
      }
      
      // If no studio of this type exists, create one
      String name;
      String description;
      
      switch (type) {
        case StudioType.recording:
          name = 'Recording Studio';
          description = 'Main recording studio space';
          break;
        case StudioType.production:
          name = 'Production Studio';
          description = 'Main production studio space';
          break;
        case StudioType.hybrid:
          name = 'Hybrid Studio';
          description = 'Combined recording and production studio space';
          break;
      }
      
      // Create the studio
      final studio = Studio(
        name: name,
        type: type,
        description: description,
        status: StudioStatus.available,
      );
      
      // Insert the studio and return its ID
      return await DBService.insertStudio(studio);
    } catch (e) {
      // If there's an error, return null
      return null;
    }
  }
  
  /// Convert a list of Bookings to a list of BookingV2s
  static Future<List<BookingV2>> toBookingV2List(List<Booking> bookings) async {
    final result = <BookingV2>[];
    
    for (final booking in bookings) {
      result.add(await toBookingV2(booking));
    }
    
    return result;
  }
  
  /// Convert a list of BookingV2s to a list of Bookings
  static Future<List<Booking>> toBookingList(List<BookingV2> bookingsV2) async {
    final result = <Booking>[];
    
    for (final bookingV2 in bookingsV2) {
      result.add(await toBooking(bookingV2));
    }
    
    return result;
  }
}
