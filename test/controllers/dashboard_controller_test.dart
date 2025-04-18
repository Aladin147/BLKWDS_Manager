import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/screens/dashboard/dashboard_controller.dart';
import '../mocks/mock_build_context.dart';

// No need to generate mocks for this simplified test
void main() {
  late DashboardController controller;
  late MockBuildContext mockContext;

  setUp(() {
    // Initialize controller
    controller = DashboardController();
    mockContext = MockBuildContext();
    // No need to mock widget property as it's already implemented in MockBuildContext
    controller.setContext(mockContext);

    // No need to reset mocks for this simplified test
  });

  tearDown(() {
    // Clean up
    controller.dispose();
  });

  group('DashboardController Initialization', () {
    test('controller should have correct initial state', () {
      // Just verify the initial state of the controller
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.gearList.value, isEmpty);
      expect(controller.memberList.value, isEmpty);
      expect(controller.projectList.value, isEmpty);
      expect(controller.bookingList.value, isEmpty);
      expect(controller.studioList.value, isEmpty);
      expect(controller.recentActivity.value, isEmpty);
      expect(controller.gearOutCount.value, 0);
      expect(controller.bookingsTodayCount.value, 0);
      expect(controller.gearReturningCount.value, 0);
      expect(controller.studioBookingToday.value, null);
    });




  });

  group('DashboardController Gear Operations', () {
    test('controller should have methods for gear operations', () {
      // Verify that the controller has the expected methods
      expect(controller.checkOutGear, isA<Function>());
      expect(controller.checkInGear, isA<Function>());
    });
  });
}
